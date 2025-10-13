// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class EditUserDialogScreen extends StatefulWidget {
//   const EditUserDialogScreen({super.key});

//   @override
//   State<EditUserDialogScreen> createState() => _EditUserDialogScreenState();
// }

// class _EditUserDialogScreenState extends State<EditUserDialogScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Center(child: Text("Update User")),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextFormField(
//                 decoration: InputDecoration(
//                   hintText: "Enter name",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20.r),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
