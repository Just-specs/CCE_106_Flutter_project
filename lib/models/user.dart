
class User {
  final String username;
  final String password;
  final String role; // 'admin' or 'user'
  final String fullName;
  final String email;

  User({
    required this.username,
    required this.password,
    required this.role,
    required this.fullName,
    required this.email,
  });
}

class UserDatabase {
  // Simulated user database
  static final List<User> users = [
    // Admin account
    User(
      username: 'admin',
      password: 'admin123',
      role: 'admin',
      fullName: 'Administrator',
      email: 'admin@freshpetals.com',
    ),
    // Sample user accounts
    User(
      username: 'user',
      password: 'user123',
      role: 'user',
      fullName: 'John Doe',
      email: 'john.doe@example.com',
    ),
    User(
      username: 'customer1',
      password: 'pass123',
      role: 'user',
      fullName: 'Jane Smith',
      email: 'jane.smith@example.com',
    ),
  ];

  static User? authenticate(String username, String password) {
    try {
      return users.firstWhere(
        (user) => user.username == username && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  static bool addUser(User user) {
    // Check if username already exists
    if (users.any((u) => u.username == user.username)) {
      return false;
    }
    users.add(user);
    return true;
  }
}
