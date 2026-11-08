import re
import sys

def check_lua_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    stack = []
    for line_idx, line in enumerate(lines):
        line_num = line_idx + 1
        # remove comment
        line_clean = line.split('--')[0]
        # remove strings
        line_clean = re.sub(r'"(\\.|[^"\\])*"', '""', line_clean)
        line_clean = re.sub(r"'(\\.|[^'\\])*'", "''", line_clean)

        tokens = re.findall(r'\b(?:function|then|do|repeat|elseif|end|until)\b', line_clean)
        for t in tokens:
            if t in ('function', 'do', 'repeat'):
                stack.append((t, line_num))
            elif t == 'then':
                stack.append((t, line_num))
            elif t == 'elseif':
                if stack and stack[-1][0] == 'then':
                    stack.pop()
            elif t in ('end', 'until'):
                if stack:
                    popped = stack.pop()
                else:
                    print(f"Error: extra '{t}' at line {line_num}")

    print(f"Remaining open blocks: {len(stack)}")
    for item in stack:
        print(f"  Unclosed {item[0]} from line {item[1]}: {lines[item[1]-1].strip()}")
    return len(stack) == 0

if __name__ == '__main__':
    target = r'gameguardian-lua-script\script\mbc\mbc-assistant.lua'
    check_lua_file(target)
