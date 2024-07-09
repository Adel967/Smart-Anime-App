import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';



class Bar extends StatefulWidget {
  final String label;
  final dynamic amountSpending;
  final dynamic mostExpensive;
  final int isFirst;
  final String unit;
  final bool axis;
  const Bar({Key? key,required this.label,required this.amountSpending,required this.mostExpensive,required this.isFirst,required this.unit, required this.axis}) : super(key: key);

  @override
  State<Bar> createState() => _BarState();
}

class _BarState extends State<Bar> {
  double barLength = 0;

  setHeight(){
    final size  = MediaQuery.of(context).size;
    barLength = 0;
    setState(() {

    });
    if(widget.mostExpensive != 0){
      barLength =  (widget.amountSpending / widget.mostExpensive) * (widget.axis ? size.height * 0.21 : size.width * 0.6);
    }
    setState(() {

    });
  }

  @override
  void didUpdateWidget(covariant Bar oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    if (oldWidget != widget) {
      setHeight();
    }
  }

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 10),setHeight);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size  = MediaQuery.of(context).size;
    DateTime now = DateTime.now();
    String today  = DateFormat('EEEE').format(now).substring(0,2);

    return Container(
      height: widget.axis ? size.height * 0.28 : 20,
      alignment: Alignment.bottomCenter,
      child: widget.axis ? Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AutoSizeText(
            '${widget.amountSpending is double ? widget.amountSpending.toStringAsFixed(1) : widget.amountSpending}\ ${widget.unit} ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 8.0),
          AnimatedContainer(
            duration: Duration(seconds: 1),
            height: widget.axis ? barLength : 10,
            width: widget.axis ? 18 : barLength,
            decoration: BoxDecoration(
                color: Color(0xFFEB1555),
                borderRadius: BorderRadius.circular(6.0)
            ),

          ),
          SizedBox(height: 8.0),
          Text(
            widget.label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
                color: today == widget.label && widget.isFirst == 1 ? Colors.greenAccent : Colors.white
            ),
          ),
        ],
      ) :
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              widget.label,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                  color: today == widget.label && widget.isFirst == 1 ? Colors.greenAccent : Colors.white
              ),
            ),
          ),
          SizedBox(width: widget.amountSpending ==0 ? 0 : 8.0),
          Flexible(
            child: AnimatedContainer(
              duration: Duration(seconds: 1),
              height: widget.axis ? barLength : 8,
              width: widget.axis ? 18 : barLength,
              decoration: BoxDecoration(
                  color: Color(0xFFEB1555),
                  borderRadius: BorderRadius.circular(6.0)
              ),

            ),
          ),
          SizedBox(width: 8.0),
          Text(
            '${widget.amountSpending is double ? widget.amountSpending.toStringAsFixed(1) : widget.amountSpending}\ ${widget.unit} ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 15
            ),
          ),

        ],
      ),
    );
  }
}
