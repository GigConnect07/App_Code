class NetworkCard extends StatelessWidget {
  final String name;
  final String role;
  final String location;

  const NetworkCard({
    super.key,
    required this.name,
    required this.role,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFBA55D3).withOpacity(0.1),
                child: const Icon(Icons.person, size: 30),
              ),
              const SizedBox(height: 10),
              Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              Text(role,
                  style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 5),
              Text(location,
                  style: TextStyle(
                      color: Color(0xFFBA55D3),
                      fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}