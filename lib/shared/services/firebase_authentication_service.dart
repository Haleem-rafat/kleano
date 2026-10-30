// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';

// import 'package:crypto/crypto.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class FirebaseAuthenticationService {
//   static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

//   static final User? _firebaseUser = _firebaseAuth.currentUser;

//   User? get currentUser => _firebaseUser;
//   FirebaseAuth get firebaseAuth => _firebaseAuth;

//   /// Notifies about changes to the user's sign-in state (such as sign-in or sign-out).
//   StreamSubscription<User?> listenToAuthStateChanges(
//     void Function(User?)? onData, {
//     Function? onError,
//     void Function()? onDone,
//     bool? cancelOnError,
//   }) {
//     return firebaseAuth.authStateChanges().listen(
//           onData,
//           onError: onError,
//           onDone: onDone,
//           cancelOnError: cancelOnError,
//         );
//   }

//   // Future<UserCredential?> signInWithGoogle() async {
//   //   final GoogleSignIn googleSignIn = GoogleSignIn(
//   //     scopes: <String>[
//   //       'email',
//   //       'profile',
//   //     ],
//   //   );

//   //   final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

//   //   if (googleUser == null) {
//   //     return null;
//   //   }

//   //   final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//   //   final OAuthCredential credential = GoogleAuthProvider.credential(
//   //     accessToken: googleAuth.accessToken,
//   //     idToken: googleAuth.idToken,
//   //   );

//   //   return await FirebaseAuth.instance.signInWithCredential(credential);
//   // }

//   // Future<UserCredential?> signInWithFacebook() async {
//   //   final LoginResult loginResult = await FacebookAuth.instance.login();

//   //   if (loginResult.accessToken != null) {
//   //     final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);
//   //     return firebaseAuth.signInWithCredential(facebookAuthCredential);
//   //   } else {
//   //     return null;
//   //   }
//   // }

//   String generateNonce([int length = 32]) {
//     const String charset =
//         '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
//     final Random random = Random.secure();
//     return List<String>.generate(
//       length,
//       (_) => charset[random.nextInt(charset.length)],
//     ).join();
//   }

//   /// Returns the sha256 hash of [input] in hex notation.
//   String sha256ofString(String input) {
//     final List<int> bytes = utf8.encode(input);
//     final Digest digest = sha256.convert(bytes);
//     return digest.toString();
//   }

//   // Future<UserCredential> signInWithApple() async {
//   //   // To prevent replay attacks with the credential returned from Apple, we
//   //   // include a nonce in the credential request. When signing in with
//   //   // Firebase, the nonce in the id token returned by Apple, is expected to
//   //   // match the sha256 hash of `rawNonce`.
//   //   final String rawNonce = generateNonce();
//   //   final String nonce = sha256ofString(rawNonce);

//   //   // Request credential for the currently signed in Apple account.
//   //   // final AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
//   //   //   scopes: <AppleIDAuthorizationScopes>[
//   //   //     AppleIDAuthorizationScopes.email,
//   //   //     AppleIDAuthorizationScopes.fullName,
//   //   //   ],
//   //   //   nonce: nonce,
//   //   // );

//   //   // Create an `OAuthCredential` from the credential returned by Apple.
//   //   // final OAuthCredential oauthCredential = OAuthProvider("apple.com").credential(
//   //   //   idToken: appleCredential.identityToken,
//   //   //   rawNonce: rawNonce,
//   //   // );

//   // //  return await firebaseAuth.signInWithCredential(oauthCredential);
//   // }

//   static Future<void> sendPasswordResetEmail({required String email}) async {
//     return _firebaseAuth.sendPasswordResetEmail(
//       email: email,
//     );
//   }

//   static Future<void> confirmPasswordReset(
//       {required String code, required String newPassword}) async {
//     return _firebaseAuth.confirmPasswordReset(
//       code: code,
//       newPassword: newPassword,
//     );
//   }
// }
