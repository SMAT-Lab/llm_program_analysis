'\n    The approach taken is explained below. I decided to do it simply.\n    Initially I was considering parsing the data into some sort of\n    structure and then generating an appropriate README. I am still\n    considering doing it - but for now this should work. The only issue\n    I see is that it only sorts the entries at the lowest level, and that\n    the order of the top-level contents do not match the order of the actual\n    entries.\n\n    This could be extended by having nested blocks, sorting them recursively\n    and flattening the end structure into a list of lines. Revision 2 maybe ^.^.\n'
def sort_blocks():
    with open('README.md', 'r') as read_me_file:
        read_me = read_me_file.read()
    table_of_contents = ''.join(read_me.split('- - -')[0])
    blocks = ''.join(read_me.split('- - -')[1]).split('\n# ')
    for i in range(len(blocks)):
        if i == 0:
            blocks[i] = blocks[i] + '\n'
        else:
            blocks[i] = '# ' + blocks[i] + '\n'
    inner_blocks = sorted(blocks[0].split('##'))
    for i in range(1, len(inner_blocks)):
        if inner_blocks[i][0] != '#':
            inner_blocks[i] = '##' + inner_blocks[i]
    inner_blocks = ''.join(inner_blocks)
    blocks[0] = inner_blocks
    final_README = table_of_contents + '- - -' + ''.join(blocks)
    with open('README.md', 'w+') as sorted_file:
        sorted_file.write(final_README)
with open('README.md', 'r') as read_me_file:
    read_me = read_me_file.read()
read_me = read_me_file.read()
table_of_contents = ''.join(read_me.split('- - -')[0])
blocks = ''.join(read_me.split('- - -')[1]).split('\n# ')
i
range(len(blocks))
i Eq 0
inner_blocks = sorted(blocks[0].split('##'))
blocks[i] = blocks[i] + '\n'
blocks[i] = '# ' + blocks[i] + '\n'
i
range(1, len(inner_blocks))
inner_blocks[i][0] NotEq '#'
inner_blocks = ''.join(inner_blocks)
blocks[0] = inner_blocks
final_README = table_of_contents + '- - -' + ''.join(blocks)
with open('README.md', 'w+') as sorted_file:
    sorted_file.write(final_README)
sorted_file.write(final_README)
def main():
    with open('README.md', 'r') as read_me_file:
        read_me = read_me_file.readlines()
    blocks = []
    last_indent = None
    for line in read_me:
        s_line = line.lstrip()
        indent = len(line) - len(s_line)
        if any([s_line.startswith(s) for s in ['* [', '- [']]):
            if indent == last_indent:
                blocks[-1].append(line)
            else:
                blocks.append([line])
            last_indent = indent
        else:
            blocks.append([line])
            last_indent = None
    with open('README.md', 'w+') as sorted_file:
        blocks = [''.join(sorted(block, key=str.lower)) for block in blocks]
        sorted_file.write(''.join(blocks))
    sort_blocks()
with open('README.md', 'r') as read_me_file:
    read_me = read_me_file.readlines()
read_me = read_me_file.readlines()
blocks = []
last_indent = None
inner_blocks[i] = '##' + inner_blocks[i]
line
read_me
s_line = line.lstrip()
indent = len(line) - len(s_line)
any([s_line.startswith(s) for s in ['* [', '- [']])
with open('README.md', 'w+') as sorted_file:
    blocks = [''.join(sorted(block, key=str.lower)) for block in blocks]
    sorted_file.write(''.join(blocks))
blocks = [''.join(sorted(block, key=str.lower)) for block in blocks]
sorted_file.write(''.join(blocks))
sort_blocks()
__name__ Eq '__main__'
indent Eq last_indent
blocks.append([line])
last_indent = None
blocks[-1].append(line)
blocks.append([line])
last_indent = indent
main()