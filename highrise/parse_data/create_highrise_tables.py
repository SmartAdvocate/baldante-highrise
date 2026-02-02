from sqlalchemy import Table, Column, Integer, String, MetaData, ForeignKey, text
import logging

logger = logging.getLogger(__name__)

def create_tables(engine):
    metadata = MetaData()

    contacts_table = Table('contacts', metadata,
        Column('id', Integer, primary_key=True, autoincrement=False),
        Column('name', String),
        Column('tags', String),
        Column('company_id', String),
        Column('company_name', String),
        Column('background', String),
        Column('filename', String),
    )

    phone_table = Table('phone', metadata,
        Column('id', Integer, primary_key=True, autoincrement=True),
        Column('contact_id', Integer),  # Add foreign key to 'contacts'
        Column('phone_number', String)
    )

    email_address_table = Table('email_address', metadata,
        Column('id', Integer, primary_key=True, autoincrement=True),
        Column('contact_id', Integer),  # Add foreign key to 'contacts'
        Column('email_address', String)
    )

    address_table = Table('address', metadata,
        Column('id', Integer, primary_key=True, autoincrement=True),
        Column('contact_id', Integer),  # Add foreign key to 'contacts'
        Column('address', String),
        Column('street', String),
        Column('city', String),
        Column('state', String),
        Column('zip', String)
    )

    notes_table = Table('notes', metadata,
        Column('id', Integer, primary_key=True, autoincrement=True),
        Column('note_key', String),
        Column('contact_id', Integer),  # Foreign key to 'contacts'
        Column('company_id', Integer),  # Foreign key to 'company'
        Column('author', String),
        Column('written_date', String),  # You can change this to DateTime if you want to store actual dates
        Column('about', String),
        Column('body', String)
    )

    tasks_table = Table('tasks', metadata,
        Column('id', Integer, primary_key=True, autoincrement=True),
        Column('task_key', String),
        Column('contact_id', Integer),  # Foreign key to 'contacts'
        Column('company_id', Integer),  # Foreign key to 'company'
        Column('author', String),
        Column('written_date', String),  # You can change this to DateTime if you want to store actual dates
        Column('about', String),
        Column('body', String)
    )

    emails_table = Table('emails', metadata,
        Column('id', Integer, primary_key=True, autoincrement=True),
        Column('email_key', String),
        Column('contact_id', Integer),  # Foreign key to 'contacts'
        Column('company_id', Integer),  # Foreign key to 'company'
        Column('author', String),
        Column('written_date', String),  # You can change this to DateTime if you want to store actual dates
        Column('subject', String),  # You can change this to DateTime if you want to store actual dates
        Column('about', String),
        Column('body', String)
    )

    """
    1. Connect to the database using the provided engine.
    2. Look at all tables stored in 'metadata'.
    3. Create any tables that do not already exist in the database.
    """
    metadata.create_all(engine)

    logging.info(f"Tables created successfully: {metadata.tables.keys()}")