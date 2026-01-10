import 'dart:io';

//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:nurebo_admin/widgets/select_image.dart';
import 'package:http/http.dart' as http;
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';


class EventImagesWidget extends StatefulWidget {
  final String? text;
  final int? numImages;
  final List? images;

  EventImagesWidget({
    Key? key, this.text,
    this.numImages,
    this.images
  });

  @override
  _EventImagesWidgetState createState() => _EventImagesWidgetState();
}

class _EventImagesWidgetState extends State<EventImagesWidget> {
  late File _image;
  final picker = ImagePicker();
  bool isSelectedImage = false;

  Future choiceImage() async {
    // var pickedImage = await picker.getImage(source: ImageSource.gallery);
    var pickedImage = await picker.pickImage(source: ImageSource.gallery);
    // PickedFile pickedImage = await picker.getVideo(source: ImageSource.gallery);

    // _video = File(pickedFile.path);
    setState(() {
      _image = File(pickedImage!.path);
      isSelectedImage = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 10),
              child: Text(
                widget.text ?? 'Immagini',
                // 'Immagini',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blue[500],
                  fontWeight: FontWeight.w600
                ),
              ),
            ),
            Container(
              height: 100,
              //wrapparlo con futurebuilder per creare l image file dall' image network
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                // itemCount: (row.state as List).length,
                // itemCount: widget.numImages,
                itemCount: widget.images!.length,
                itemBuilder: (BuildContext context, int index) {
                  // _image = images[index];
                  // print(widget.images.length);
                  return InkWell(
                    onTap: (){
                      // print('ciao');
                      choiceImage();
                      // print('_image.path');
                      // print(_image.path);
                      // return SelectImageView(
                      //   selected: (image /*= FileImage().images[index]*/) async {
                      //     // images[index];
                      //     //实际情况是上传照片 返回图片URL，这里模拟数据使用路径
                      //     // row.state[index]["picurl"] = image.path;
                      //   },
                      // );
                    },
                    child: isSelectedImage == false && widget.images![index] != null ? FutureImage(
                      widget.images![index],
                      width: MediaQuery.of(context).size.width,
                    ) : isSelectedImage == true ? Image.file(_image) : Container(
                      width: 110,
                      height: 100,
                      // margin: EdgeInsets.all(5),
                      color: Colors.grey[200],
                    ),
                  );

                  // return SelectImageView(
                  //   selected: (image) async {
                  //     final response = await http.get(images[index]);
                  //     final documentDirectory = await getApplicationDocumentsDirectory();
                  //     final file = File(join(documentDirectory.path, images[index].toString().substring(15)));
                  //     file.writeAsBytesSync(response.bodyBytes);
                  //     image = file;
                  //     // Directory dir = await getApplicationDocumentsDirectory();
                  //     // String pathName = p.join(dir.path, filename);
                  //     // var myImageFile = File(pathName);
                  //     // images[index];
                  //     //实际情况是上传照片 返回图片URL，这里模拟数据使用路径
                  //     // row.state[index]["picurl"] = image.path;
                  //   },
                  // );
                },
              ),
            ),
            SizedBox(height: 15,),
          ],
        ),
      ),
    );
  }
}
