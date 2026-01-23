import os
import re
import logging
# Highrise functions
from .create_highrise_tables import create_tables
from .extract_contact import extract_contact
from .extract_company import extract_company
# Logging and utility functions
from lib.utility.create_engine import main as create_engine
from lib.logging.logger_config import logger_config
# External libraries
from rich.prompt import Confirm
from rich.progress import Progress, SpinnerColumn, BarColumn, TextColumn, TimeElapsedColumn, TaskProgressColumn
from rich.console import Console

console = Console()

# Global logger config at the top-level
script_name = os.path.splitext(os.path.basename(__file__))[0]
logger = logger_config(name=script_name, log_file=f"{script_name}.log", level=logging.DEBUG)

def main(directory, engine, console):

    # logger = logger_config(__name__, log_file="extract_highrise.log", rich_console=console)
    # logger = logging.getLogger(__name__)
    logger.info(f"Starting extraction from directory: {directory}")
    all_files = [f for f in os.listdir(directory) if f.endswith('.txt')]
    total_files = len(all_files)

    if total_files == 0:
        logger.info(f"No .txt files found in {directory}")
        return

    if not Confirm.ask(
        f"Import all .txt files in {directory} --> {engine.url.host}.{engine.url.database}?"
    ):
        logger.info(f"Execution skipped for {directory}.")
        return

    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        BarColumn(),
        TaskProgressColumn(),
        "•",
        TimeElapsedColumn(),
        "•",
        TextColumn("{task.completed}/{task.total} files"),
        console=console,
        transient=False
    ) as progress:
        
        task = progress.add_task(f"[cyan]Processing files...", total=total_files)

        for filename in all_files:
            file_path = os.path.join(directory, filename)

            progress.update(task, description=f"[cyan]Processing {filename}")
            
            try:
                # File starts with a digit, it's a company
                if re.match(r'^\d', filename):
                    extract_company(file_path, engine, progress=progress)
                # otherwise, it is a contact
                else:
                    extract_contact(file_path, engine, progress=progress)
            except Exception as e:
                logger.error(f"Error processing {filename}: {e}")
                progress.console.print(f"[red]ERROR: {filename}: {e}[/red]")

            progress.advance(task)

        progress.update(task, description="[green]Processing Complete")


if __name__ == '__main__':
    script_name = os.path.splitext(os.path.basename(__file__))[0]
    logger_config(name="", log_file=f"{script_name}.log", level=logging.INFO)
    logger = logging.getLogger(__name__)
    
    import argparse
    parser = argparse.ArgumentParser(description="Process SQL files and save results to an Excel file.")
    parser.add_argument("-s", "--server", required=True, help="SQL Server")
    parser.add_argument("-d", "--database", required=True, help="Database")
    parser.add_argument("-i", "--input", required=True, help="Path to the input folder containing SQL files.")
    
    args = parser.parse_args()

    engine = create_engine(server=args.server, database=args.database)
    create_tables(engine)
    main(args.input, engine, console=console)