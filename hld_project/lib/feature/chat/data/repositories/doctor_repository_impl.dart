import 'package:hld_project/feature/chat/data/datasources/doctor_remote_datasource.dart';
import 'package:hld_project/feature/chat/data/models/doctor_model.dart';
import 'package:hld_project/feature/chat/domain/entities/doctor.dart';
import 'package:hld_project/feature/chat/domain/repositories/doctor_repository.dart';

class DoctorRepositoryImpl implements DoctorRepository{

  final DoctorRemoteDatasource _datasource;

  DoctorRepositoryImpl(this._datasource);

  @override
  Future<void> CreateDoctor(Doctor doctor) async {
    final model = DoctorModel.fromEntity(doctor);
      await _datasource.CreateDoctor(model);
  }

  @override
  Future<void> DeleteDoctor(String id)  async {
    await _datasource.DeleteDoctor(id);
  }

  @override
  Future<Doctor?> GetDoctorbyID(String id) async {
    final model =  await _datasource.getDoctorByID(id);
    return model?.toEntity();
  }

  @override
  Future<List<Doctor>> GetAllDoctor()  async {
    final model = await _datasource.GetAllDoctor();
    return model.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> UpdateDoctor(Doctor doctor) async {
    final model = await DoctorModel.fromEntity(doctor);
    await _datasource.UpdateDoctor(model);
  }

}