import 'package:flutter/material.dart';

class CustomDropDownButton extends StatefulWidget {
  final List<String> textList;
  final void Function(String) function;
  final List<String> unClickableItems;
  String dropDownValue;

  CustomDropDownButton({Key? key, required this.textList,required this.function,required this.unClickableItems,this.dropDownValue ="" }) : super(key: key);

  @override
  _CustomDropDownButtonState createState() => _CustomDropDownButtonState();
}

class _CustomDropDownButtonState extends State<CustomDropDownButton> {



  @override
  void initState() {
    super.initState();
    if(widget.dropDownValue.isEmpty){
      widget.dropDownValue = widget.textList[0];
    }
    print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
    print(widget.dropDownValue = widget.textList[0]);
    setState(() {

    });

  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      itemBuilder: (context) {
        return widget.textList.map((str) {
          return PopupMenuItem(
            value: str,
            child: Text(
              str,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: widget.unClickableItems.contains(str) ? Colors.grey : Colors.black
              ),
            ),
          );
        }).toList();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            widget.dropDownValue,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600
            ),
          ),
          Icon(Icons.arrow_drop_down,size: 25,color: Color(0xFFEB1555),),
        ],
      ),
      onSelected: (v) {
        if(!widget.unClickableItems.contains(v)){
          setState(() {
            widget.dropDownValue = v;
            widget.function(v);
          });
        }
      },
    );
  }
}