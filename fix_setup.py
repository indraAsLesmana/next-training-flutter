import re

with open("docs/setup.md", "r") as f:
    content = f.read()

# Replace tab-set blocks
content = re.sub(r'````\{tab-set\}', '::::{tab-set}', content)
content = re.sub(r'```\{tab-item\}', ':::{tab-item}', content)
content = re.sub(r'```\n```\{tab-item\}', ':::\n:::{tab-item}', content)
content = re.sub(r'```\n````', ':::\n::::', content)

# Write back
with open("docs/setup.md", "w") as f:
    f.write(content)

