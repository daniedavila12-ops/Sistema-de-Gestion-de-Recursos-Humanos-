import json
chunks = json.load(open('chunks.json', encoding='utf-8'))
for c in chunks:
    print('Tool:', c['name'])
    args = c['args']
    if 'ReplacementChunks' in args:
        print('Number of chunks:', len(args['ReplacementChunks']))
        for i, chunk in enumerate(args['ReplacementChunks']):
            print('Chunk target lines:', chunk.get('StartLine'), '-', chunk.get('EndLine'))

