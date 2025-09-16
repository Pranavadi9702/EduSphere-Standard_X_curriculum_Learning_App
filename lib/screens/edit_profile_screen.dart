import 'package:e_learning_app/screens/privacy.dart';
import 'package:e_learning_app/screens/terms_conditions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  String? selectedIdentity;
  String? profileImageUrl; // To store the profile image URL
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  User? user;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _fetchUserData();
    }
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          this.user = user;
          _fetchUserData();
        });
      }
    });
  }

  Future<String> _uploadImageToStorage(File imageFile) async {
    String filePath = 'profile_images/${user!.uid}.jpg';
    Reference ref = FirebaseStorage.instance.ref().child(filePath);
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (snapshot.exists) {
        // Firestore data exists
        setState(() {
          userData = snapshot.data() as Map<String, dynamic>?;

          _emailController.text = userData?['email'] ?? user!.email ?? '';
          _firstNameController.text = userData?['firstName'] ?? '';
          _lastNameController.text = userData?['lastName'] ?? '';
          _dobController.text = userData?['dob'] ?? '';
          _mobileController.text = userData?['mobile'] ?? '';
          selectedIdentity = userData?['identity'] ?? '';
          profileImageUrl = userData?['profileImageUrl'] ?? user!.photoURL;
        });
      } else {
        // No Firestore data, use Firebase Auth for Google sign-in users
        String? displayName = user!.displayName;
        String firstName = '';
        String lastName = '';

        if (displayName != null) {
          firstName = displayName; // Use the full name
          lastName = ''; // Clear last name field
        }

        setState(() {
          _emailController.text = user!.email ?? '';
          _firstNameController.text =
              firstName; // Set full name to first name field
          _lastNameController.text = lastName;
          _dobController.text = '';
          _mobileController.text = '';
          selectedIdentity = '';
          profileImageUrl = user!.photoURL;
        });

        // Save initial Google user data to Firestore
        Map<String, dynamic> newUserData = {
          'email': user!.email ?? '',
          'firstName': firstName,
          'lastName': lastName,
          'dob': '',
          'mobile': '',
          'identity': '',
          'profileImageUrl': user!.photoURL ?? '',
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .set(newUserData);
      }
    }
  }

  Future<void> _initializeFirestoreUser() async {
    if (user == null) return;
    Map<String, dynamic> defaultData = {
      'email': user!.email ?? '',
      'firstName': user!.displayName?.split(' ')[0] ?? '',
      'lastName': (user!.displayName?.split(' ').length ?? 0) > 1
          ? user!.displayName?.split(' ')[1]
          : '',
      'dob': '',
      'mobile': '',
      'identity': '',
      'profileImageUrl': user!.photoURL ?? '',
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .set(defaultData, SetOptions(merge: true));

    setState(() {
      userData = defaultData;
      _emailController.text = defaultData['email'];
      _firstNameController.text = defaultData['firstName'];
      _lastNameController.text = defaultData['lastName'];
      _dobController.text = defaultData['dob'];
      _mobileController.text = defaultData['mobile'];
      selectedIdentity = defaultData['identity'];
      profileImageUrl = defaultData['profileImageUrl'];
    });
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
    Navigator.pop(context);
  }

  void showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Color(0xFF1D56CF)),
              title: Text("Take Photo"),
              onTap: () => pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.image, color: Color(0xFF1D56CF)),
              title: Text("Choose from Gallery"),
              onTap: () => pickImage(ImageSource.gallery),
            ),
            if (_profileImage != null)
              ListTile(
                leading: Icon(Icons.delete, color: Color(0xFF1D56CF)),
                title: Text("Remove Photo",
                    style: TextStyle(color: Color(0xFF1D56CF))),
                onTap: () {
                  setState(() {
                    _profileImage = null;
                  });
                  Navigator.pop(context);
                },
              ),
          ],
        );
      },
    );
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  Future<void> saveChanges() async {
    if (user != null) {
      Map<String, dynamic> updatedData = {
        'email': _emailController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'dob': _dobController.text,
        'mobile': _mobileController.text,
        'identity': selectedIdentity,
      };

      if (_profileImage != null) {
        // TODO: Upload image to Firebase Storage and update the URL in Firestore
        // updatedData['profileImageUrl'] = uploadedImageUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set(updatedData, SetOptions(merge: true));

      // Refresh profile after saving
      _fetchUserData();

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Color(0xFF1D56CF),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.02),
            Center(
              child: GestureDetector(
                onTap: showImagePickerOptions,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: screenWidth * 0.14,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (profileImageUrl != null
                              ? NetworkImage(profileImageUrl!)
                              : null),
                      child: _profileImage == null && profileImageUrl == null
                          ? Icon(Icons.perm_identity,
                              size: screenWidth * 0.14, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: GestureDetector(
                        onTap: showImagePickerOptions,
                        child: CircleAvatar(
                          radius: screenWidth * 0.045,
                          backgroundColor: Color(0xFF1D56CF),
                          child: Icon(Icons.edit,
                              color: Colors.white, size: screenWidth * 0.04),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildContainer(
              children: [
                SizedBox(height: screenHeight * 0.01),
                _buildSectionTitle(
                  "Mobile Number",
                ),
                SizedBox(height: screenHeight * 0.01),
                _buildInputField("Enter Mobile Number",
                    controller: _mobileController, isNumber: true),
                SizedBox(height: screenHeight * 0.02),
                _buildSectionTitle(
                  "Email Address",
                ),
                SizedBox(height: screenHeight * 0.01),
                _buildInputField("Enter Email",
                    withCheck: true, controller: _emailController),
                SizedBox(height: screenHeight * 0.01),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildContainer(
              children: [
                _buildSectionTitle("Personal Details"),
                _buildInputLabel("First Name"),
                _buildInputField("Enter Name",
                    controller: _firstNameController),
                _buildInputLabel("Last Name"),
                _buildInputField("Enter Surname",
                    controller: _lastNameController),
                _buildInputLabel("Date Of Birth (Optional)"),
                _buildDOBField(),
                _buildInputLabel("Identity (Optional)"),
                _buildChoiceButtons(["Male", "Female"]),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),

            // Terms & Conditions Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("I agree to ",
                        style: TextStyle(fontSize: 10, color: Colors.black)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const TermsConditionsPage()),
                        );
                      },
                      child: Text(
                        "Terms & Conditions",
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1D56CF),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF1D56CF)),
                      ),
                    ),
                    Text(" and ",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                        )),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrivacyPage(),
                          ),
                        );
                      },
                      // Handle Privacy Policy tap

                      child: Text(
                        "Privacy Policy",
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1D56CF),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF1D56CF)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.06),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(screenWidth * 0.02),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1D56CF).withOpacity(0.9),
            minimumSize: Size(double.infinity, screenHeight * 0.06),
          ),
          onPressed: saveChanges,
          child: Text("Save Changes",
              style: TextStyle(
                  color: Colors.white, fontSize: screenWidth * 0.045)),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Widget? button}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Spacer(),
        if (button != null) button,
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 5),
      child: Text(label,
          style: TextStyle(
              fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
    );
  }

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegex.hasMatch(email);
  }

  Widget _buildInputField(String hint,
      {bool withCheck = false,
      bool isNumber = false,
      TextEditingController? controller}) {
    return TextField(
      controller: controller,
      keyboardType:
          isNumber ? TextInputType.number : TextInputType.emailAddress,
      inputFormatters: isNumber
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10)
            ]
          : [],
      onChanged: (value) {
        setState(() {}); // Refresh UI when user types
      },
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        counterText: "", // Hide default character counter
        suffixIcon:
            withCheck && controller != null && isValidEmail(controller.text)
                ? Icon(Icons.check_circle, color: Colors.green)
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _buildDOBField() {
    return TextField(
      controller: _dobController,
      readOnly: true,
      onTap: () => selectDate(context),
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: "DD/MM/YYYY",
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.calendar_today, color: Color(0xFF1D56CF)),
              onPressed: () => selectDate(context),
            ),
            if (_dobController.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, color: Color(0xFF1D56CF)),
                onPressed: () {
                  setState(() {
                    _dobController.clear();
                  });
                },
              ),
          ],
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _buildEditButton(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: TextButton(
        onPressed: () {},
        child: Text(text, style: TextStyle(color: Color(0xFF1D56CF))),
      ),
    );
  }

  Widget _buildChoiceButtons(List<String> options) {
    return Row(
      children: options.map((option) {
        bool isSelected = selectedIdentity == option;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? Color(0xFF1D56CF) : Colors.white,
              side: BorderSide(
                  color: isSelected ? Color(0xFF1D56CF) : Colors.black),
            ),
            onPressed: () {
              setState(() {
                selectedIdentity = option;
              });
            },
            child: Text(option,
                style:
                    TextStyle(color: isSelected ? Colors.white : Colors.black)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContainer({required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 1)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
