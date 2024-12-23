import 'package:flutter/material.dart';
import 'package:kanver/src/home/home.dart';
import 'package:kanver/src/widgets/requestDetailCard.dart';

class RequestDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kan Bağışı İsteği'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32.0, 38.0, 32.0, 32.0),
                child: Column(
                  children: [
                    const CustomCard(
                        title: "Gereken Kan",
                        desc: "0 rh-",
                        icon: Icon(Icons.bloodtype)),
                    const SizedBox(height: 16),
                    const CustomCard(
                        title: "Gereken Donör Sayısı",
                        desc: "2 ünite kan",
                        icon: Icon(Icons.monitor_heart)),
                    const SizedBox(height: 16),
                    const CustomCard(
                        title: "Hasta Yaşı",
                        desc: "23",
                        icon: Icon(Icons.person)),
                    const SizedBox(height: 16),
                    const CustomCard(
                        title: "Hastane",
                        desc: "İstinye Sarıyer Devlet Hastanesi",
                        icon: Icon(Icons.local_hospital)),
                    const SizedBox(height: 16),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: 'Ek Bilgiler: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                                'Hasta çok ağır bir trafik kazası geçirdi ve bugün akşam 8’de ameliyata girecek.',
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff65558F),
                  foregroundColor: Colors.white,
                ),
                
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const AlertDialog(
                        title: Text("Başlık"),
                        content: Text("İçerik"),
                      );
                    },
                  );
                },
                label: const Text("Bağış Yapacağım"),
                icon: const Icon(Icons.check),
              ),
            )
          ],
        ),
      ),
    );
  }
}
