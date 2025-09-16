// import 'package:flutter/material.dart';
// import 'comments_widget.dart';
// import 'community_first.dart'; // Ensure this import is correct

// class CommentWidget extends StatelessWidget {
//   final Comment comment;
//   final Function(Comment) onReply;
//   final Function(Comment) onLike;
//   final Function(Comment) onDislike;

//   CommentWidget({
//     required this.comment,
//     required this.onReply,
//     required this.onLike,
//     required this.onDislike,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             comment.user,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(
//             comment.text,
//             style: TextStyle(color: Colors.black87),
//           ),
//           SizedBox(height: 8),
//           Row(
//             children: [
//               IconButton(
//                 onPressed: () => onLike(comment),
//                 icon: Icon(
//                   Icons.thumb_up,
//                   color: comment.userLiked == true ? Colors.blue : Colors.black54,
//                 ),
//               ),
//               Text("${comment.likes}", style: TextStyle(color: Colors.black54)),
//               IconButton(
//                 onPressed: () => onDislike(comment),
//                 icon: Icon(
//                   Icons.thumb_down,
//                   color: comment.userLiked == false ? Colors.red : Colors.black54,
//                 ),
//               ),
//               Text("${comment.dislikes}", style: TextStyle(color: Colors.black54)),
//               IconButton(
//                 onPressed: () => onReply(comment),
//                 icon: Icon(Icons.reply, color: Colors.black54),
//               ),
//             ],
//           ),
//           if (comment.replies.isNotEmpty)
//             ...comment.replies.map(
//                   (reply) => Padding(
//                 padding: const EdgeInsets.only(left: 16.0),
//                 child: CommentWidget(
//                   comment: reply,
//                   onReply: onReply,
//                   onLike: onLike,
//                   onDislike: onDislike,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }