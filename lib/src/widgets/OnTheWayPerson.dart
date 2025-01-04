import 'package:flutter/material.dart';
import 'package:intl/intl.dart';                // <-- Import intl
import 'package:kanver/services/request_service.dart';

class OnTheWayCard extends StatefulWidget {
  final String donorName;
  final String donorSurname;
  final String donorBloodType;
  final String donorCity;
  final String initialStatus;
  final int onTheWayId;
  final DateTime? createTime;                   // <-- Field for date
  final int requestId;
  final Function? checkOnTheWayCount;

  const OnTheWayCard({
    Key? key,
    required this.donorName,
    required this.donorSurname,
    required this.donorBloodType,
    required this.donorCity,
    required this.initialStatus,
    required this.onTheWayId,
    this.createTime,
    this.checkOnTheWayCount,
    required this.requestId,
  }) : super(key: key);

  @override
  _OnTheWayCardState createState() => _OnTheWayCardState();
}

class _OnTheWayCardState extends State<OnTheWayCard> {
  late String _status; // Local state variable for status

  @override
  void initState() {
    super.initState();
    // Initialize _status with the initialStatus passed from the parent
    _status = widget.initialStatus;
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Left Icon or Avatar
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person, color: Colors.black),
            ),
            // Donor Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.donorName} ${widget.donorSurname}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Kan: ${widget.donorBloodType}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    widget.donorCity.isNotEmpty 
                        ? widget.donorCity 
                        : "Şehir bilgisi yok",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    widget.createTime != null
                        ? _formatTime(widget.createTime!)
                        : 'Bilinmiyor',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            // Right-Side Button or Status
            if (_status == 'on_the_way')
              ElevatedButton(
                onPressed: () {
                  _showConfirmationBottomSheet(context);
                },
                child: const Text(
                  'Bağışı Onayla',
                  style: TextStyle(fontSize: 12),
                ),
              )
            else
              Text(
                _status == 'completed' ? 'Tamamlandı' : _status,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationBottomSheet(BuildContext context) {
    // A local loading flag for the bottom sheet content
    bool _localLoading = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext bottomSheetContext, StateSetter setModalState) {
            return Container(
              color: Colors.white,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, 
                    vertical: 24.0
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Bağışı tamamlamak istediğinize emin misiniz?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _localLoading
                                ? null
                                : () {
                                    setModalState(() {
                                      _localLoading = true;
                                    });
                                    BloodRequestService()
                                        .setCompletedOnTheWay(
                                      onTheWayId: widget.onTheWayId,
                                      requestId: widget.requestId,
                                    )
                                        .then(
                                      (value) {
                                        setModalState(() {
                                          _localLoading = false;
                                        });

                                        if (value["success"]) {
                                          // Update the local _status of the main widget
                                          setState(() {
                                            _status = 'completed';
                                          });
                                          Navigator.pop(ctx);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(value["message"]),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                    ).catchError(
                                      (error) {
                                        setModalState(() {
                                          _localLoading = false;
                                        });
                                        Navigator.pop(ctx);
                                      },
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                            ),
                            child: _localLoading
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text('İşleniyor...'),
                                    ],
                                  )
                                : const Text('Evet'),
                          ),
                          OutlinedButton(
                            onPressed: _localLoading
                                ? null
                                : () {
                                    Navigator.pop(ctx);
                                  },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Hayır'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      if(_status == 'completed') {
        if(widget.checkOnTheWayCount?.call()){
            Navigator.pop(context);
        }
      }
    });
  }
}
