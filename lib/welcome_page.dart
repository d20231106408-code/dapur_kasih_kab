import 'package:flutter/material.dart';
import 'login_page.dart'; 

// ---------------------------------------------------------
// WELCOME PAGE 
// ---------------------------------------------------------
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Stack lets us place widgets layer by layer on top of each other
      body: Stack(
        children: [
          // LAYER 1: Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/dapur.jpg'),
                fit: BoxFit.cover, // Ensures the image stretches to fill the screen
              ),
            ),
          ),

          // LAYER 2: Dark Overlay
          // Images can sometimes be too bright, making white text hard to read.
          // This adds a semi-transparent black tint over the image.
          Container(
            color: Colors.black.withOpacity(0.35),
          ),

          // LAYER 3: Foreground (Text and Button)
          // SafeArea ensures your UI doesn't hide under the phone's notch or status bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0), // Side margins
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the left
                children: [
                  // Spacer acts like an invisible spring, pushing the text down
                  const Spacer(flex: 3),

                  // --- Main Title ---
                  const Text(
                    'Welcome to\nDapurKasih',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      height: 1.05, // Controls the space between the two lines
                    ),
                  ),

                  const SizedBox(height: 20), // Spacing between title and subtitle

                  // --- Subtitle ---
                  // RichText allows us to combine multiple text styles in one line
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(
                          text: "Kolej Aminuddin Baki (KAB)\n",
                          style: TextStyle(color: Colors.white),
                        ),
                        // FIX: Removed the 'child:' label here
                        TextSpan(
                          text: "Let's Get ",
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: "Started !",
                          style: TextStyle(color: Color(0xFFFF7A22)), // Custom Orange
                        ),
                      ],
                    ),
                  ),

                  // This Spacer pushes the button down to the bottom area
                  const Spacer(flex: 4),

                  // --- Action Button ---
                  SizedBox(
                    width: double.infinity, // Makes the button stretch the full width
                    height: 55, // Height of the button
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7A22), // Orange color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                        ),
                      ),
                      onPressed: () {
                        // Navigation Logic: Go to the Login Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      // FIX: Adjusted grammar to "Get Started"
                      child: const Text(
                        "Get Started",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40), // Padding at the very bottom of the screen
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
