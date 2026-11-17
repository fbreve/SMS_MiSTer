import re
from collections import Counter

with open('C:/Users/fbrev/.gemini/antigravity/brain/3a84772c-afc5-4c52-ad3e-fa0e08942b04/.system_generated/tasks/task-5878.log', 'r') as f:
    text = f.read()

print('Summary line:')
for line in text.splitlines():
    if 'Errors:' in line and 'Warnings:' in line:
        print(' ', line.strip())

matches = re.findall(r'\*\* Warning: (.*?)(?=\r?\n)', text)
print(f'Total "** Warning:" occurrences: {len(matches)}')

c = Counter()
for w in matches:
    if '(vcom-1200)' in w:
        c['(vcom-1200) Function return type index bounds'] += 1
    elif 'in an arithmetic operand, the result will be' in w:
        c['Arithmetic operand with U/X at startup'] += 1
    elif 'CONV_INTEGER:' in w:
        c['CONV_INTEGER: U/X in arithmetic operand converted to 0'] += 1
    elif '(vlib-34)' in w:
        c['(vlib-34) Library already exists'] += 1
    else:
        c[w[:60]] += 1

for k, v in c.items():
    print(f'  {v:3d}x {k}')
print(f'Sum of all categorized warnings: {sum(c.values())}')

