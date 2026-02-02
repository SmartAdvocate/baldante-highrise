import logging
import re
from pathlib import Path

# Highrise functions
from highrise.parse_data.create_highrise_tables import create_tables
from .parse_notes_tasks_emails import parse_notes_tasks_emails

# Utility functions
from lib.utility.create_engine import main as create_engine
from lib.utility.insert_sql import insert_to_sql_server
from lib.utility.insert_helpers import insert_entities
from lib.utility.load_yaml import load_yaml

# External libraries
from rich.console import Console

logger = logging.getLogger(__name__)
console = Console()


def clean_and_parse_address(raw_address):
    """
    Parses messy addresses like: 
    'Inmate # QP3589 SCI Mahanoy 301 Grey Line Drive, Frackville, PA, 17931'
    """
    # Standardize: remove trailing commas and line breaks
    addr = raw_address.replace('\n', ', ').strip().strip(',')
    parts = [p.strip() for p in addr.split(',')]
    
    result = {
        'street': addr, # Default to full string if parsing fails
        'city': None,
        'state': None,
        'zip': None
    }

    # Work backwards from the end of the list
    # 1. Check for Zip (5 digits)
    if parts and re.search(r'\d{5}', parts[-1]):
        result['zip'] = parts.pop()
    
    # 2. Check for State (usually 2 chars or full name)
    if parts:
        result['state'] = parts.pop()
        
    # 3. Check for City
    if parts:
        result['city'] = parts.pop()
        
    # 4. Remaining parts are the street (including the 'Inmate #' noise)
    if parts:
        result['street'] = ', '.join(parts)
        
    return result

def _handle_insert_error(entity_type, identifier, file_path, error, progress):
    """Unified error logging for contact detail inserts."""
    msg = f"FAIL: insert {entity_type} {identifier} from {file_path}: {error}"
    logger.error(msg)
    if progress:
        progress.console.print(f"[red]{entity_type.capitalize()} insert failed: {file_path}: {error}[/red]")

def process_phones(contact_id, phone_list, engine, file_path, progress):
    for phone_number in phone_list:
        phone_data = {'contact_id': contact_id, 'phone_number': phone_number}
        try:
            insert_to_sql_server(file_path, engine, 'phone', phone_data, console=progress.console if progress else None)
            logger.info(f"Inserted Phone record: {phone_data}")
        except Exception as e:
            _handle_insert_error('phone', phone_number, file_path, e, progress)

def process_emails(contact_id, email_list, engine, file_path, progress):
    for email_address in email_list:
        email_data = {'contact_id': contact_id, 'email_address': email_address}
        try:
            insert_to_sql_server(file_path, engine, 'email_address', email_data, console=progress.console if progress else None)
            logger.info(f"Inserted Email record: {email_data}")
        except Exception as e:
            _handle_insert_error('email', email_address, file_path, e, progress)

def process_addresses(contact_id, address_list, engine, file_path, progress):
    for address in address_list:
        # Handle both strings and multiline objects
        raw_str = address if isinstance(address, str) else ', '.join([line.strip() for line in address.splitlines()])
        
        # Parse the address components
        parsed = clean_and_parse_address(raw_str)
        
        address_data = {
            'contact_id': contact_id, 
            'address': raw_str, # Keep the original just in case
            'street': parsed['street'],
            'city': parsed['city'],
            'state': parsed['state'],
            'zip': parsed['zip']
        }
        
        try:
            insert_to_sql_server(file_path, engine, 'address', address_data, console=progress.console if progress else None)
            logger.info(f"Inserted Parsed Address: {parsed['city']}, {parsed['state']}")
        except Exception as e:
            _handle_insert_error('address', raw_str, file_path, e, progress)
    # for address in address_list:
    #     formatted_address = address.strip() if isinstance(address, str) else ', '.join([line.strip() for line in address.splitlines()])
    #     address_data = {'contact_id': contact_id, 'address': formatted_address}
    #     try:
    #         insert_to_sql_server(file_path, engine, 'address', address_data, console=progress.console if progress else None)
    #         logger.info(f"Inserted Address record: {address_data}")
    #     except Exception as e:
    #         _handle_insert_error('address', formatted_address, file_path, e, progress)

def parse_contact_header(data, file_path):
    """ Contact Record -----------------------------------------------------------------------------
    id = data[0]['ID']
    name = data[0]['Name']
    tags = data[0]['Tags']
    company_id = data[0]['CompanyID']
    company_name = data[0]['CompanyName']
    background = data[3]['Background']
    """
    
    contact_header = data[0]
    
    company_info = None
    if len(data) > 1:
        company_info = {
            'ID': data[1].get('ID'),
            'Name': data[1].get('Name')
    }

    background = None
    if len(data) > 3 and isinstance(data[3], dict) and 'Background' in data[3]:
        background = data[3]['Background']

    contact_data = {
        'id': contact_header.get('ID'),
        'name': contact_header.get('Name'),
        'tags': ', '.join(contact_header.get('Tags', [])) if contact_header.get('Tags') else None,
        'company_id': company_info.get('ID') if company_info else None,
        'company_name': company_info.get('Name') if company_info else None,
        'background': background,
        # 'filename': file_path.split('\\')[-1]  # Extract the file name from the path
        'filename': Path(file_path).name  # Extract the file name from the path
    }
    logger.debug(f"Parsed contact header: {contact_data}")
    return contact_data

def parse_contact_info(data, contact_id, engine, file_path, progress=None):
    
    # if len(data) <= 2 or 'Contact' not in data[2]:
    #     return

    # contact_items = data[2]['Contact']
    
    # Find the dictionary that contains the 'Contact' key
    contact_block = next((item for item in data if isinstance(item, dict) and 'Contact' in item), None)

    if not contact_block:
        logger.warning(f"No 'Contact' block found in {file_path}. Data length: {len(data)}")
        return

    contact_items = contact_block['Contact']

    for item in contact_items:
        if not isinstance(item, list) or not item:
            continue

        label = item[0]
        values = item[1]

        if 'Phone_numbers' in label:
            process_phones(contact_id, values, engine, file_path, progress)
        elif 'Email_addresses' in label:
            process_emails(contact_id, values, engine, file_path, progress)
        elif 'Addresses' in label:
            process_addresses(contact_id, values, engine, file_path, progress)
                                  
# def parse_contact_info(data, contact_id, engine, file_path, progress=None):
#     if len(data) > 2 and 'Contact' in data[2]:
#         contact_info = data[2]['Contact']
#         phone_numbers = []
#         email_addresses = []

#         for item in contact_info:
#             # Phone numbers ----------------------------------------------------
#             if isinstance(item, list) and 'Phone_numbers' in item[0]:
#                 phone_numbers = item[1]
#                 for phone_number in phone_numbers:
#                     phone_data = {
#                         'contact_id': contact_id,
#                         'phone_number': phone_number
#                     }

#                     try:
#                         insert_to_sql_server(file_path, engine, 'phone', phone_data, console=progress.console if progress else None)
#                         logger.debug(f"Inserted Phone record: {phone_data}")
#                     except Exception as e:
#                         logger.error(f"FAIL: insert phone {phone_number} from {file_path}: {e}")
                        
#                         if progress:
#                             progress.console.print(f"[red]Phone insert failed: {file_path}: {e}[/red]")

#             # Email addresses ----------------------------------------------------
#             if isinstance(item, list) and 'Email_addresses' in item[0]:
#                 email_addresses = item[1]
                
#                 for email_address in email_addresses:
#                     email_data = {
#                         'contact_id': contact_id,
#                         'email_address': email_address
#                     }

#                     try:
#                         insert_to_sql_server(file_path, engine, 'email_address', email_data, console=progress.console if progress else None)
#                         logger.debug(f"Inserted Email record: {email_data}")
#                     except Exception as e:
#                         logger.error(f"FAIL: insert email {email_address} from {file_path}: {e}")
                        
#                         if progress:
#                             progress.console.print(f"[red]Email insert failed: {file_path}: {e}[/red]")


#             # Addresses ----------------------------------------------------
#             if isinstance(item, list) and 'Addresses' in item[0]:
#                 raw_addresses = item[1]
#                 for address in raw_addresses:
#                     if isinstance(address, str):
#                         formatted_address = address.strip()
#                     else:
#                         # Format multiline addresses
#                         formatted_address = ', '.join([line.strip() for line in address.splitlines()])

#                     address_data = {
#                         'contact_id': contact_id,
#                         'address': formatted_address
#                     }
                
#                     try:
#                         insert_to_sql_server(file_path, engine, 'address', address_data, console=progress.console if progress else None)
#                         logger.debug(f"Inserted Address record: {address_data}")
#                     except Exception as e:
#                         logger.error(f"FAIL: insert address {formatted_address} from {file_path}: {e}")
                        
#                         if progress:
#                             progress.console.print(f"[red]Address insert failed: {file_path}: {e}[/red]")


def extract_contact(file_path, engine, progress=None):
    
    logger.debug(f"Processing contact file: {file_path}")
    data = load_yaml(file_path, console=progress.console if progress else None)
    if not data:
        return 

    # Contact Header
    contact_data = parse_contact_header(data, file_path)
    insert_to_sql_server(file_path, engine, 'contacts', contact_data, console=progress.console if progress else None)
    logger.info(f"Inserted Contact record: {contact_data}")

    # Contact Information
    parse_contact_info(data, contact_data['id'], engine, file_path, progress)

    # Notes, Tasks, Emails
    notes, tasks, emails = parse_notes_tasks_emails(data, contact_id=contact_data['id'])

    # insert_entities(file_path, engine, notes, "notes", "note", contact_data['id'], progress)
    # insert_entities(file_path, engine, tasks, "tasks", "task", contact_data['id'], progress)
    # insert_entities(file_path, engine, emails, "emails", "email", contact_data['id'], progress)

    for n in notes:
        try:
            insert_to_sql_server(file_path, engine, 'notes', n, console=progress.console if progress else None)
        except Exception as e:
            logger.error(f"Note insert failed for contact {contact_data['id']}: {e}")
    for t in tasks:
        try:
            insert_to_sql_server(file_path, engine, 'tasks', t, console=progress.console if progress else None)
        except Exception as e:
            logger.error(f"Task insert failed for contact {contact_data['id']}: {e}")

    for e in emails:
        try:
            insert_to_sql_server(file_path, engine, 'emails', e, console=progress.console if progress else None)
        except Exception as e:
            logger.error(f"Email insert failed for contact {contact_data['id']}: {e}")



if __name__ == '__main__':
   
    import argparse
    parser = argparse.ArgumentParser(description="Process SQL files and save results to an Excel file.")
    parser.add_argument("-s", "--server", required=True, help="SQL Server")
    parser.add_argument("-d", "--database", required=True, help="Database")
    parser.add_argument("-i", "--input", required=True, help="Path to the input folder containing SQL files.")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable DEBUG logging to console")
    
    args = parser.parse_args()

    # Configure logging so DEBUG messages are visible when requested
    log_level = logging.DEBUG if args.verbose else logging.INFO
    logging.basicConfig(level=log_level, format='%(levelname)s %(name)s: %(message)s')

    engine = create_engine(server=args.server, database=args.database)
    create_tables(engine)
    extract_contact(args.input, engine, progress=None)