import 'package:flutter/material.dart';

import '../../../../../domain/entities/pet_clinical_draft.dart';

/// Lista editable de medicamentos: nombre, dosis, frecuencia, duración.
/// Permite agregar y eliminar filas dinámicamente.
class MedicationEditor extends StatefulWidget {
  const MedicationEditor({
    super.key,
    required this.medications,
    required this.accentColor,
    required this.onChanged,
  });

  final List<ClinicalMedicationDraft> medications;
  final Color accentColor;
  final ValueChanged<List<ClinicalMedicationDraft>> onChanged;

  @override
  State<MedicationEditor> createState() => _MedicationEditorState();
}

class _MedicationEditorState extends State<MedicationEditor> {
  static const _textDark = Color(0xFF1A1A2E);
  static const _textMuted = Color(0xFF6B7280);
  static const _inputFill = Color(0xFFEEF3F3);

  late List<ClinicalMedicationDraft> _items = List.of(widget.medications);

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textMuted, fontSize: 13),
        filled: true,
        fillColor: _inputFill,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      );

  void _add() {
    setState(() => _items.add(ClinicalMedicationDraft.empty()));
    widget.onChanged(_items);
  }

  void _remove(int index) {
    setState(() => _items.removeAt(index));
    widget.onChanged(_items);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Sin medicamentos agregados.',
              style: const TextStyle(fontSize: 13, color: _textMuted),
            ),
          ),
        for (var i = 0; i < _items.length; i++) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE0E4EC)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Medicamento ${i + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _remove(i),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF0ED),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFD05A24)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _items[i].name,
                  style: const TextStyle(fontSize: 13, color: _textDark),
                  decoration: _decoration('Nombre del medicamento'),
                  onChanged: (v) {
                    _items[i].name = v;
                    widget.onChanged(_items);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _items[i].dose,
                        style: const TextStyle(fontSize: 13, color: _textDark),
                        decoration: _decoration('Dosis'),
                        onChanged: (v) {
                          _items[i].dose = v.isEmpty ? null : v;
                          widget.onChanged(_items);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: _items[i].frequency,
                        style: const TextStyle(fontSize: 13, color: _textDark),
                        decoration: _decoration('Frecuencia'),
                        onChanged: (v) {
                          _items[i].frequency = v.isEmpty ? null : v;
                          widget.onChanged(_items);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _items[i].duration,
                  style: const TextStyle(fontSize: 13, color: _textDark),
                  decoration: _decoration('Duración (ej. 7 días)'),
                  onChanged: (v) {
                    _items[i].duration = v.isEmpty ? null : v;
                    widget.onChanged(_items);
                  },
                ),
              ],
            ),
          ),
        ],
        OutlinedButton.icon(
          onPressed: _add,
          icon: Icon(Icons.add_rounded, size: 18, color: widget.accentColor),
          label: Text('Agregar medicamento', style: TextStyle(color: widget.accentColor)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: widget.accentColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ],
    );
  }
}
