import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String desc;
  final Widget? icon;
  final Icon? additionalIcon;

  const CustomCard({
    Key? key,
    required this.title,
    required this.desc,
    this.icon,
    this.additionalIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: Color(0xffFEF7FF),
            ),
            child: Center(
              child: icon,
            ),
          ),
          SizedBox(width: 15), // Gap of 10 pixels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff49454F),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xff6750A4),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
       
          additionalIcon ?? Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: Color(0xffFfFfFF),
            ),
            child: Center(
              child: additionalIcon
            ),
          ),
        ],
      ),
    );
  }
}



  //   Card(
  //     elevation: 4,
  //     margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
  //     child: ListTile(
  //       leading: icon,
  //       title: Text(title),
  //       subtitle: Text(desc),
  //     ),
  //   );
  // }
// }
