class SkillSelectionSheet extends StatefulWidget {
  final String workerType;
  final Function(List<String>) onSkillsSelected;

  const SkillSelectionSheet({
    super.key,
    required this.workerType,
    required this.onSkillsSelected,
  });

  @override
  State<SkillSelectionSheet> createState() => _SkillSelectionSheetState();
}

class _SkillSelectionSheetState extends State<SkillSelectionSheet> {
  final Map<String, List<String>> skillDatabase = {
    'Mason': ['Bricklaying', 'Stonework', 'Concrete Finishing', 'Block Walls'],
    'Electrician': ['Wiring', 'Circuit Installation', 'Safety Systems'],
    'Plumber': ['Pipe Fitting', 'Drain Cleaning', 'Water Heater Installation'],
  };

  List<String> selectedSkills = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
      Text(
      "Select skills for ${widget.workerType}",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 20),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: skillDatabase[widget.workerType]!.map((skill) {
          return FilterChip(
            label: Text(skill),
            selected: selectedSkills.contains(skill),
            onSelected: (selected) => setState(() {
              selected
                  ? selectedSkills.add(skill)
                  : selectedSkills.remove(skill);
            }),
            selectedColor: const Color(0xFFBA55D3).withOpacity(0.3),
          );
        }).toList(),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () {
          widget.onSkillsSelected(selectedSkills);
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFBA55D3)),
      ),
      child: const Text("Confirm Skills"),
    )
    ],
    ),
    );
  }
}