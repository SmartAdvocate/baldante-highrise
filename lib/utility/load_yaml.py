import yaml
import logging
import re

logger = logging.getLogger(__name__)

def _sanitize_yaml_block_scalars(content):
    """
    Fix malformed YAML block scalars from Highrise exports.
    
    Root cause: Highrise exports use block scalar indicators (|, |-, |+) with:
    1. Invalid indent numbers (|10-, |16- etc, YAML only allows 1-9)
    2. Insufficient content indentation
    3. Content that contains YAML syntax (colons, ---, etc)
    
    Solution: Use literal block scalars (|) with proper indentation to preserve
    content exactly as-is without interpreting YAML syntax.
    """
    lines = content.split('\n')
    fixed_lines = []
    i = 0
    
    while i < len(lines):
        line = lines[i]
        
        # Match array item with block scalar: "  - |10-" or "  - |-"
        array_match = re.match(r'^(\s*)- ([|>])(\d*)([+\-]?)\s*$', line)
        
        if array_match:
            prefix = array_match.group(1)
            indicator = array_match.group(2)
            
            # Collect content lines
            content_lines = []
            i += 1
            
            # Get indentation level for comparison
            item_indent = len(prefix) + 2  # "- " is 2 chars
            
            while i < len(lines):
                next_line = lines[i]
                
                if not next_line.strip():
                    content_lines.append(next_line)
                    i += 1
                    continue
                
                next_indent = len(next_line) - len(next_line.lstrip())
                
                # If line is at or less indented than list item, we've exited
                if next_indent <= len(prefix):
                    break
                
                content_lines.append(next_line)
                i += 1
            
            # Reconstruct as proper literal block scalar with correct indentation
            # Use |- (strip final newlines) to avoid extra blank lines
            fixed_lines.append(f'{prefix}- |-')
            
            # Add content with proper indentation (must be indented more than list marker)
            content_indent = item_indent + 2
            for content_line in content_lines:
                if not content_line.strip():
                    # Empty lines - output as blank
                    fixed_lines.append('')
                else:
                    # Non-empty line - strip and re-indent to required level
                    content_text = content_line.lstrip()
                    spaces = ' ' * content_indent
                    fixed_lines.append(spaces + content_text)
        else:
            # Try to match regular key: value | pattern
            key_match = re.match(r'^(\s*(?:- )?)(\w+):\s*([|>])(\d*)([+\-]?)\s*$', line)
            
            if key_match:
                prefix = key_match.group(1)
                key_name = key_match.group(2)
                indicator = key_match.group(3)
                
                # Collect content lines
                content_lines = []
                i += 1
                
                # Get indentation level
                key_indent = len(prefix)
                
                while i < len(lines):
                    next_line = lines[i]
                    
                    if not next_line.strip():
                        content_lines.append(next_line)
                        i += 1
                        continue
                    
                    next_indent = len(next_line) - len(next_line.lstrip())
                    
                    # If line is at or less indented than key, we've exited
                    if next_indent <= key_indent:
                        break
                    
                    content_lines.append(next_line)
                    i += 1
                
                # Reconstruct as proper literal block scalar with correct indentation
                # Use |- (strip final newlines) to avoid trailing blanks
                fixed_lines.append(f'{prefix}{key_name}: |-')
                
                # Add content with proper indentation (must be indented more than key)
                content_indent = key_indent + 2
                for content_line in content_lines:
                    if not content_line.strip():
                        # Empty lines - output as blank
                        fixed_lines.append('')
                    else:
                        # Non-empty line - strip and re-indent to required level
                        content_text = content_line.lstrip()
                        spaces = ' ' * content_indent
                        fixed_lines.append(spaces + content_text)
            else:
                # Not a block scalar line
                fixed_lines.append(line)
                i += 1
    
    return '\n'.join(fixed_lines)

def load_yaml(file_path, console=None):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()
        
        # Preprocess the YAML to fix block scalar issues
        fixed_content = _sanitize_yaml_block_scalars(content)
        
        return yaml.safe_load(fixed_content)
    except yaml.YAMLError as exc:
        logger.error(f"Error parsing YAML file {file_path}: {exc}")
        if console:
            console.print(f"[red]Error parsing YAML file {file_path}[/red]")
        return None
    except Exception as e:
        logger.error(f"Unexpected error loading YAML file {file_path}: {e}")
        if console:
            console.print(f"[red]Unexpected error loading YAML file {file_path}[/red]")
        return None
