import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:eden/app/modules/prediction/domain/entities/prediction_entity.dart';
import 'package:eden/app/modules/prediction/domain/usecases/load_model.dart';
import 'package:eden/app/modules/prediction/domain/usecases/prediction.dart';
import 'package:eden/app/modules/prediction/domain/usecases/save_prediction.dart';
import 'package:eden/app/modules/prediction/domain/usecases/upload_file.dart';
import 'package:eden/app/modules/prediction/presentation/states/prediction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';
import 'package:asuka/asuka.dart' as asuka;

part 'prediction_controller.g.dart';

@Injectable()
class PredictionController = _PredictionController with _$PredictionController;

abstract class _PredictionController with Store {
  final LoadModel loadModelUseCase;
  final Prediction predictionUseCase;
  final UploadFile uploadFileUseCase;
  final SavePrediction savePredictionUseCase;

  _PredictionController(this.loadModelUseCase, this.predictionUseCase, this.uploadFileUseCase, this.savePredictionUseCase);

  Future<PredictionState> prediction(PickedFile image) async {
    loadModelUseCase();
    Either<Exception, List<dynamic>> output = await predictionUseCase(image);
    return output.fold((failure) {
      asuka.showSnackBar(SnackBar(content: Text(failure.toString())));
      return setState(ErrorState(failure));
    }, (List<dynamic> output) {
      return setState(SuccessState(output));
    });
  }

  Future<String> upload(File file, String folder, String name, String extension) async {
    return await uploadFileUseCase(file, folder, name, extension);
  }

  Future<DocumentReference> savePrediction(PredictionEntity prediction) async {
    return await savePredictionUseCase(prediction);
  }

  @observable
  PredictionState state = StartState();

  @action
  setState(PredictionState value) => state = value;
}