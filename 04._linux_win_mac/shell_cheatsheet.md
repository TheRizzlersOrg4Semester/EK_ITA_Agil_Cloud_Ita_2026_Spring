# Shell Cheat Sheet

## Basic Commands

### `ls -l`
The `ls` command lists files and directories. The `-l` flag provides a detailed (long) listing format, showing:
- File permissions
- Number of links
- Owner name
- Group name
- File size
- Last modified date/time
- File/directory name

Example:
```bash
ls -l
```

Example output:
```
-rw-r--r--  1 user group  1024 Jan 1 12:34 file.txt
drwxr-xr-x  2 user group  4096 Jan 1 12:35 directory
```

### `chmod`
The `chmod` command changes file permissions. Permissions can be set using:
- **Symbolic mode**: `u` (user), `g` (group), `o` (others), `a` (all)
- **Numeric mode**: Octal numbers (e.g., `755`, `644`)

Example (add execute permission for user):
```bash
chmod +x script.sh
```

Example (set permissions to `rw-r--r--`):
```bash
chmod 644 file.txt
```

### File Permissions (`-rw-r--r--`)
This permission string breaks down as:
- `-`: File type ( `-` = regular file, `d` = directory)
- `rw-`: User (owner) permissions (read, write, no execute)
- `r--`: Group permissions (read, no write, no execute)
- `r--`: Others permissions (read, no write, no execute)

## Text Processing

### `grep`
The `grep` command searches for patterns in files or input.

Example (search for "error" in a file):
```bash
grep "error" log.txt
```

Example (case-insensitive search):
```bash
grep -i "warning" log.txt
```

## Pipes

### `|` (Pipe Operator)
Pipes redirect the standard output of one command to the standard input of another.

Example (count lines containing "error"):
```bash
cat log.txt | grep "error" | wc -l
```

### `>` (Redirect Output)
Overwrites a file with command output.

Example:
```bash
ls -l > file_list.txt
```

### `>>` (Append Output)
Appends command output to a file.

Example:
```bash
echo "New line" >> file.txt
```



## Bash Scripts

### Creating a Script

1. Write a script (e.g., `script.sh`):

```bash
    #!/bin/bash
    echo "Hello, World!"
```

2. Make it executable:

```bash
    chmod +x script.sh
```

3. Run the script:

```bash
    ./script.sh
```

### Making Scripts Executable
Use `chmod +x` to grant execute permission:
```bash
    chmod +x script.sh
```

This allows the script to be run directly (e.g., `./script.sh`).
