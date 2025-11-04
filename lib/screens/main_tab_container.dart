// // screens/main_tab_container.dart
// import 'package:flutter/material.dart';
// import 'home_screen.dart';
// import 'profile_screen.dart';
//
// // TẠO MÀN HÌNH PLACEHOLDER CHO CÁC TAB CÒN LẠI
// class PlaceholderScreen extends StatelessWidget {
//   final String title;
//   const PlaceholderScreen(this.title, {Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         title,
//         style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
// }
//
// class MainTabContainer extends StatefulWidget {
//   final int initialIndex;
//   const MainTabContainer({Key? key, this.initialIndex = 0}) : super(key: key);
//
//   @override
//   State<MainTabContainer> createState() => _MainTabContainerState();
// }
//
// class _MainTabContainerState extends State<MainTabContainer> {
//   late int _currentIndex;
//
//   // ĐẢM BẢO CÓ ĐỦ 5 MÀN HÌNH
//   final List<Widget> _screens = [
//      HomeScreen(),
//      PlaceholderScreen('Mall'),
//      PlaceholderScreen('Live & Video'),
//      PlaceholderScreen('Thông báo'),
//     const ProfileScreen(),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//   }
//
//   void _onTabTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _currentIndex,
//         children: _screens,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _currentIndex,
//         selectedItemColor: Colors.red,
//         unselectedItemColor: Colors.grey,
//         onTap: _onTabTapped,
//         items: [
//           const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           const BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Mall'),
//           BottomNavigationBarItem(
//             icon: Stack(
//               children: [
//                 const Icon(Icons.tv),
//                 Positioned(
//                   right: 0,
//                   top: 0,
//                   child: Container(
//                     padding: EdgeInsets.all(2),
//                     decoration: BoxDecoration(
//                       color: Colors.red,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     constraints: BoxConstraints(minWidth: 16, minHeight: 16),
//                     child: Text(
//                       'Mới!',
//                       style: TextStyle(color: Colors.white, fontSize: 8),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             label: 'Live & Video',
//           ),
//           BottomNavigationBarItem(
//             icon: Stack(
//               children: [
//                 const Icon(Icons.notifications),
//                 Positioned(
//                   right: 0,
//                   top: 0,
//                   child: Container(
//                     padding: EdgeInsets.all(2),
//                     decoration: BoxDecoration(
//                       color: Colors.red,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     constraints: BoxConstraints(minWidth: 16, minHeight: 16),
//                     child: Text(
//                       '16',
//                       style: TextStyle(color: Colors.white, fontSize: 10),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             label: 'Thông báo',
//           ),
//           const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Tôi'),
//         ],
//       ),
//     );
//   }
// }