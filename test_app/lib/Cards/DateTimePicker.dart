import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class DateTimePicker extends StatefulWidget {
  final String text;
  late String? initialTime ;

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  DateTimePicker( {Key? key, required this.text, dateController , timeController , initialTime }) : super( key: key ) {
    if( dateController != null ) {
      this.dateController = dateController;
    }
    if( timeController != null ) {
      this.timeController = timeController;
    }
    if( initialTime != null ) {
      this.initialTime = initialTime;
    }
    else {
      this.initialTime = '';
    }
  }

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {

  late double _height, _width;

  late String _setTime , _setDate;
  late String dateTime ;

  DateTime selectedDate = DateTime.now();
  late TimeOfDay selectedTime;

  @override
  void initState( ) {
    // initializing date and time controllers
    widget.dateController.text = DateFormat.yMd().format( DateTime.now() );

    if( widget.initialTime == '' ) {
      selectedTime = TimeOfDay( hour: 00, minute: 00 );
    }
    else {
      selectedTime = TimeOfDay( hour: int.parse( widget.initialTime!.split(':')[0] ), minute: int.parse( widget.initialTime!.split(':')[1] ) );
    }

    super.initState();
  }

  String getTime( ) {
    return this._setTime;
  }

  String getDate() {
    return this._setDate;
  }

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
        widget.dateController.text =  DateFormat.yMd().format( selectedDate );
      });
    }
  }

  Future<void> selectTime( BuildContext context ) async {

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if( picked != null ) {
      setState( () {
        selectedTime = picked ;
        widget.timeController.text = formatDate(
          DateTime( selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute, 0 ),
          [ HH ,':', nn, ":", ss ] ).toString();
      } );

    }
  }

  @override
  Widget build( BuildContext context ) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width ;

    dateTime = DateFormat.yMd().format( DateTime.now() );

    return Container(
      color: Colors.white,
      width: 350.0 ,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget> [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric( horizontal: 5.0 ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.text,
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  selectTime(context);
                },
                child: Container(
                  margin: EdgeInsets.only(top: 30),
                  width: _width / 7,
                  height: _height / 7,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular( 20.0 ),
                  ),
                  child: TextFormField(
                    style: TextStyle(fontSize: 40),
                    textAlign: TextAlign.center,
                    onSaved: (String? val) {
                      _setTime = val!;
                    },
                    enabled: false,
                    keyboardType: TextInputType.text,
                    controller: widget.timeController,
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
    );
  }
}