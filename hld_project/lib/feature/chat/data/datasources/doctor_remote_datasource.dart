

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hld_project/core/data/firebase_remote_datasource.dart';
import 'package:hld_project/feature/Product/data/datasource/product_repository_datasource.dart';
import 'package:hld_project/feature/chat/data/models/doctor_model.dart';

import '../../domain/entities/doctor.dart';

abstract class DoctorRemoteDatasource{
  Future<List<DoctorModel>> GetAllDoctor();
  Future<DoctorModel?> getDoctorByID(String id);
  Future<void> DeleteDoctor(String id);
  Future<void> CreateDoctor(DoctorModel doctor);
  Future<void> UpdateDoctor(DoctorModel doctor);
}
class DoctorRemoteDataSourceImpl implements DoctorRemoteDatasource{
  final FirebaseRemoteDS<DoctorModel> _remoteDS;

  DoctorRemoteDataSourceImpl():
    _remoteDS = FirebaseRemoteDS<DoctorModel>(
    collectionName: 'doctors',
    fromFirestore: (doc) => DoctorModel.fromFirestore(doc),
    toFirestore: (model) => model.toJson(),
  );

  @override
  Future<void> CreateDoctor(DoctorModel doctormd) async {
    final doctor = await _remoteDS.add(doctormd);
  }

  @override
  Future<void> DeleteDoctor(String id) async {
    await _remoteDS.delete(id);
  }

  @override
  Future<void> UpdateDoctor(DoctorModel doctormd) async {
    await _remoteDS.update(doctormd.id.toString(),doctormd);
  }

  @override
  Future<List<DoctorModel>> GetAllDoctor() async {
    return await _remoteDS.getAll();
  }

  @override
  Future<DoctorModel?> getDoctorByID(String id) async {
    return await  _remoteDS.getById(id);
  }
}