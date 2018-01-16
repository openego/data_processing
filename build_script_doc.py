import re
import os

__PATH = 'dataprocessing/sql_snippets' 
__KEYS = ['description', 'copyright', 'license', 'url', 'author']

SPACER = '  '

expr = r"""\/\*\s*
(?P<description>.*)\s*
__copyright__\s*=\s*"(?P<copyright>.*)"\s*
__license__\s*=\s*"(?P<license>.*)"\s*
__url__\s*=\s*"(?P<url>.*)"\s*
__author__\s*=\s*"(?P<author>.*)"\s*
\*\/"""

for subdir, dirs, files in os.walk('.'):
    for fi in files:
        if fi.endswith('.sql'):
            path = os.path.join(subdir, fi)
            
            # print('Processing %s ...'%path)
            with open(path,'r') as f:
                try:
                    lines='\n'.join(f.readlines())
                except Exception as e:
                    print('Fehler in %s - abort!'%path)
                match = re.match(expr, lines)
                if match:
                    outpath = path = os.path.join('docs', fi.replace('.sql','.rst'))
                    directory = os.path.dirname(outpath)
                    if not os.path.exists(directory):
                        os.makedirs(directory)
                    
                    result = {key:match.group(key) for key in __KEYS}
                    with open(outpath, 'w') as out:
                        for key in __KEYS:
                            out.write(key+'\n')
                            out.write(SPACER+result[key].replace('\n','\n'+SPACER)+'\n')
                            out.write('\n')
                else:
                    print('No proper docstring in %s'%path)
