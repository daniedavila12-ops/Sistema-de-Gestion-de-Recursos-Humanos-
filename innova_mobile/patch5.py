import os
import sys

file_path = r'c:\Users\danie\Documents\INNOVA\Proyecto\innova_mobile\lib\features\empleados\screens\empleado_detail_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix the split bug
bad_code = """    String inicioStr = widget.empleado.fechaInicio?.split('T')[0] ?? '';
    if (inicioStr.isEmpty) return;
    
    DateTime inicio = DateTime.tryParse(inicioStr) ?? DateTime.now();
    int anioInicio = inicio.year;"""

good_code = """    if (widget.empleado.fechaInicio == null) return;
    DateTime inicio = widget.empleado.fechaInicio!;
    int anioInicio = inicio.year;"""

content = content.replace(bad_code, good_code)

# Fix the missing replacements
content = content.replace('_showVacacionDialog(context, ref, empleado.id, vacacionToEdit: vacacion)', '_showVacacionDialog(context, ref, empleado, vacacionToEdit: vacacion)')
content = content.replace('_showVacacionDialog(context, ref, empleado.id)', '_showVacacionDialog(context, ref, empleado)')


with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print('Patched successfully!')
