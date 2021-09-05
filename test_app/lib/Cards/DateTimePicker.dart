import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class DateTimePicker extends StatefulWidget {
  DateTimePicker( {Key? key }) : super( key: key );

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {

  late double _height, _width;

  late String _setTime , _setDate;

  late String _hour, _minute, _time;

  late String dateTime ;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay( hour: 00, minute: 00 );

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  Future<void> selectDate( BuildContext context ) async {
    DateTime _today = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime( _today.year, _today.month , _today.day ),
      lastDate: DateTime( _today.year, _today.month, _today.day ),
    );

    if( picked != null ) {
      setState( () {
        selectedDate = picked;
        _dateController.text =  DateFormat.yMd().format( selectedDate );
      });
    }
  }

  Future<void> selectTime( BuildContext context ) async {

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if( picked != null ) {
      setState( () {
        selectedTime = picked ;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.hour.toString();
        _time = _hour + ' : ' + _minute;
        _timeController.text = formatDate(
          DateTime( selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute),
          [hh,':', nn, " ", am ] ).toString();
      } );

    }
  }

  @override
  void initState() {
    DateTime _now = DateTime.now();

    // initializing date and time controllers

    _dateController.text = DateFormat.yMd().format( DateTime.now() );

    _timeController.text = formatDate(
      DateTime( _now.year, _now.month, _now.day , _now.hour, _now.minute ),
      [hh, ':', nn , " ", am ]
    ).toString();

    super.initState();
  }

  String getTime( ) {
    return this._setTime;
  }

  String getDate() {
    return this._setDate;
  }

  @override
  Widget build( BuildContext context ) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width ;

    dateTime = DateFormat.yMd().format( DateTime.now() );

    return Scaffold(
      backgroundColor: Colors.black26,
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).pop( [ _timeController.text ] );
        },
        child: Container(
          color: Colors.black26,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular( 20.0 ),
                color: Colors.white,
              ),
              width: _width - 200.0 ,
              height: _height - 200.0 ,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget> [
                  // Column(
                  //   children: <Widget> [
                  //     Text(
                  //       "Choose Date",
                  //       style: TextStyle(
                  //         fontStyle: FontStyle.italic,
                  //         fontWeight: FontWeight.w600,
                  //         letterSpacing: 0.5,
                  //       ),
                  //     ),
                  //     InkWell(
                  //       onTap: () {
                  //         selectDate( context );
                  //       },
                  //       child: Container(
                  //         width: _width / 1.7,
                  //         height: _height / 9,
                  //         margin: EdgeInsets.only( top: 30.0 ),
                  //         alignment: Alignment.center,
                  //         decoration: BoxDecoration(
                  //           color: Colors.grey[200],
                  //         ),
                  //         child: TextFormField(
                  //           style: TextStyle(
                  //             fontSize: 40.0,
                  //           ),
                  //           textAlign: TextAlign.center,
                  //           enabled: false,
                  //           keyboardType: TextInputType.text,
                  //           controller: _dateController,
                  //           onSaved: (String? val) {
                  //             _setDate = val!;
                  //           },
                  //           decoration: InputDecoration(
                  //             disabledBorder: UnderlineInputBorder(
                  //               borderSide: BorderSide.none,
                  //             ),
                  //             contentPadding: EdgeInsets.only( top: 0.0 )
                  //           ),
                  //         )
                  //       )
                  //     ),
                  //   ],
                  // ),
                  Column(
                    children: <Widget>[
                      Text(
                        'Choose Time',
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5),
                      ),
                      InkWell(
                        onTap: () {
                          selectTime(context);
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 30),
                          width: _width / 1.7,
                          height: _height / 9,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Colors.grey[200]),
                          child: TextFormField(
                            style: TextStyle(fontSize: 40),
                            textAlign: TextAlign.center,
                            onSaved: (String? val) {
                              _setTime = val!;
                            },
                            enabled: false,
                            keyboardType: TextInputType.text,
                            controller: _timeController,
                            decoration: InputDecoration(
                                disabledBorder:
                                UnderlineInputBorder(borderSide: BorderSide.none),
                                contentPadding: EdgeInsets.all(5)
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]
              ),
            ),
          ),
        ),
      ),
    );
  }
}