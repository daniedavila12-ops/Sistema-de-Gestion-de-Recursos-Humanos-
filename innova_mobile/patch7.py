import re

file_path = r'c:\Users\danie\Documents\INNOVA\Proyecto\innova_mobile\lib\features\empleados\screens\empleado_detail_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix the TODO comment which is just a leftover
content = content.replace('// TODO: Pass contrato object when editing via Map', '')

# Fix use_super_parameters
content = content.replace('_VacacionBottomSheet({Key? key, required this.empleado}) : super(key: key);', '_VacacionBottomSheet({super.key, required this.empleado});')

# Fix unnecessary braces
content = content.replace('${_inicioController.text}', '$_inicioController.text')
content = content.replace('${_finController.text}', '$_finController.text')
content = content.replace('${diasController.text}', '$diasController.text')
content = content.replace('${solicitudController.text}', '$solicitudController.text')
content = content.replace('${periodoController.text}', '$periodoController.text')

# Fix value -> initialValue
content = content.replace('value: _diasDisponibles.toString(),', 'initialValue: _diasDisponibles.toString(),')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print('Fixed diagnostics!')
