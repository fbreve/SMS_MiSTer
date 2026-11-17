with open('rtl/VM2413/voicerom.vhd', 'rb') as f:
    text = f.read().decode('latin1')

target = "type VOICE_ARRAY_TYPE is array (VOICE_ID_TYPE'range) of VOICE_VECTOR_TYPE;"
replacement = "type VOICE_ARRAY_TYPE is array (0 to 37) of VOICE_VECTOR_TYPE;"

if target in text:
    text = text.replace(target, replacement)
    with open('rtl/VM2413/voicerom.vhd', 'wb') as f:
        f.write(text.encode('latin1'))
    print('Updated voicerom.vhd!')
else:
    print('target not found')

