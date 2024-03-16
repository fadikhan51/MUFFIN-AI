import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../controller/image_controller.dart';
import '../../helper/global.dart';
import '../../widget/custom_btn.dart';
import '../../widget/custom_loading.dart';

class ImageFeature extends StatefulWidget {
  const ImageFeature({super.key});

  @override
  State<ImageFeature> createState() => _ImageFeatureState();
}

class _ImageFeatureState extends State<ImageFeature> {
  final _c = ImageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //app bar
      appBar: AppBar(
        title: const Text('AI Image Creator'),

        //share btn
        actions: [
          Obx(
            () => _c.status.value == Status.complete
                ? IconButton(
                    padding: const EdgeInsets.only(right: 6),
                    onPressed: _c.shareImage,
                    icon: const Icon(Icons.share))
                : const SizedBox(),
          )
        ],
      ),

      //download btn
      floatingActionButton: Obx(() => _c.status.value == Status.complete
          ? Padding(
              padding: const EdgeInsets.only(right: 6, bottom: 6),
              child: FloatingActionButton(
                onPressed: _c.downloadImage,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: const Icon(Icons.save_alt_rounded, size: 26),
              ),
            )
          : const SizedBox()),

      //body
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
            top: mq.height * .02,
            bottom: mq.height * .1,
            left: mq.width * .04,
            right: mq.width * .04),
        children: [
          //text field
          TextFormField(
            controller: _c.textC,
            textAlign: TextAlign.center,
            minLines: 2,
            maxLines: null,
            onTapOutside: (e) => FocusScope.of(context).unfocus(),
            decoration: const InputDecoration(
                hintText:
                    'Imagine something wonderful & innovative\nType here & I will create for you 😃',
                hintStyle: TextStyle(fontSize: 13.5),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)))),
          ),

          //ai image
          Container(
              height: mq.height * .5,
              margin: EdgeInsets.symmetric(vertical: mq.height * .015),
              alignment: Alignment.center,
              child: Obx(() => _aiImage())),

          Obx(() => _c.imageList.isEmpty
              ? const SizedBox(height: 1,)
              : const SizedBox(height: 2,),
          ),

          CustomBtn(onTap: _c.searchAiImage, text: 'Create'),
        ],
      ),
    );
  }

  Widget _aiImage() => ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: switch (_c.status.value) {
          Status.none =>
            Lottie.asset('assets/lottie/ai_play.json', height: mq.height * .3),
          Status.complete => Image.memory(
            base64Decode(_c.imageList.first), // 'e' is a base64 encoded string
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          ),
          Status.loading => const CustomLoading()
        },
      );
}
