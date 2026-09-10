class UtilityCompany {
  final String id;
  final String nameAr;
  final String nameEn;
  const UtilityCompany({required this.id, required this.nameAr, required this.nameEn});
}

const List<UtilityCompany> electricityCompanies = [
  UtilityCompany(id: 'elec_1', nameAr: 'شركة شمال القاهرة لتوزيع الكهرباء', nameEn: 'North Cairo Electricity Distribution Company'),
  UtilityCompany(id: 'elec_2', nameAr: 'شركة جنوب القاهرة لتوزيع الكهرباء', nameEn: 'South Cairo Electricity Distribution Company'),
  UtilityCompany(id: 'elec_3', nameAr: 'شركة الإسكندرية لتوزيع الكهرباء', nameEn: 'Alexandria Electricity Distribution Company'),
  UtilityCompany(id: 'elec_4', nameAr: 'شركة البحيرة لتوزيع الكهرباء', nameEn: 'El Beheira Electricity Distribution Company'),
  UtilityCompany(id: 'elec_5', nameAr: 'شركة شمال الدلتا لتوزيع الكهرباء', nameEn: 'North Delta Electricity Distribution Company'),
  UtilityCompany(id: 'elec_6', nameAr: 'شركة جنوب الدلتا لتوزيع الكهرباء', nameEn: 'South Delta Electricity Distribution Company'),
  UtilityCompany(id: 'elec_7', nameAr: 'شركة القناة لتوزيع الكهرباء', nameEn: 'Canal Electricity Distribution Company'),
  UtilityCompany(id: 'elec_8', nameAr: 'شركة مصر الوسطى لتوزيع الكهرباء', nameEn: 'Middle Egypt Electricity Distribution Company'),
  UtilityCompany(id: 'elec_9', nameAr: 'شركة مصر العليا لتوزيع الكهرباء', nameEn: 'Upper Egypt Electricity Distribution Company'),
];

const List<UtilityCompany> waterCompanies = [
  UtilityCompany(id: 'water_1', nameAr: 'شركة مياه الشرب بالقاهرة الكبرى', nameEn: 'Greater Cairo Drinking Water Company'),
  UtilityCompany(id: 'water_2', nameAr: 'شركة الصرف الصحي بالقاهرة الكبرى', nameEn: 'Greater Cairo Sanitary Drainage Company'),
  UtilityCompany(id: 'water_3', nameAr: 'شركة مياه الشرب بالإسكندرية', nameEn: 'Alexandria Drinking Water Company'),
  UtilityCompany(id: 'water_4', nameAr: 'شركة الصرف الصحي بالإسكندرية', nameEn: 'Alexandria Sanitary Drainage Company'),
  UtilityCompany(id: 'water_5', nameAr: 'شركة مياه الشرب والصرف الصحي بالبحيرة', nameEn: 'El Beheira Water and Wastewater Company'),
  UtilityCompany(id: 'water_6', nameAr: 'شركة مياه الشرب والصرف الصحي بالدقهلية', nameEn: 'Dakahlia Water and Wastewater Company'),
  UtilityCompany(id: 'water_7', nameAr: 'شركة مياه الشرب والصرف الصحي بالغربية', nameEn: 'Gharbia Water and Wastewater Company'),
  UtilityCompany(id: 'water_8', nameAr: 'شركة مياه الشرب والصرف الصحي بالشرقية', nameEn: 'Sharqia Water and Wastewater Company'),
  UtilityCompany(id: 'water_9', nameAr: 'شركة مياه الشرب والصرف الصحي بكفر الشيخ', nameEn: 'Kafr El Sheikh Water and Wastewater Company'),
  UtilityCompany(id: 'water_10', nameAr: 'شركة مياه الشرب والصرف الصحي بدمياط', nameEn: 'Damietta Water and Wastewater Company'),
  UtilityCompany(id: 'water_11', nameAr: 'شركة مياه الشرب والصرف الصحي بالفيوم', nameEn: 'Fayoum Water and Wastewater Company'),
  UtilityCompany(id: 'water_12', nameAr: 'شركة مياه الشرب والصرف الصحي ببني سويف', nameEn: 'Beni Suef Water and Wastewater Company'),
  UtilityCompany(id: 'water_13', nameAr: 'شركة مياه الشرب والصرف الصحي بالمنيا', nameEn: 'Minya Water and Wastewater Company'),
  UtilityCompany(id: 'water_14', nameAr: 'شركة مياه الشرب والصرف الصحي بأسوان', nameEn: 'Aswan Water and Wastewater Company'),
  UtilityCompany(id: 'water_15', nameAr: 'شركة مياه الشرب والصرف الصحي بقنا', nameEn: 'Qena Water and Wastewater Company'),
  UtilityCompany(id: 'water_16', nameAr: 'شركة مياه الشرب والصرف الصحي بالمنوفية', nameEn: 'Monufia Water and Wastewater Company'),
  UtilityCompany(id: 'water_17', nameAr: 'شركة مياه الشرب والصرف الصحي بالجيزة', nameEn: 'Giza Water and Wastewater Company'),
  UtilityCompany(id: 'water_18', nameAr: 'شركة مياه الشرب والصرف الصحي بالأقصر', nameEn: 'Luxor Water and Wastewater Company'),
  UtilityCompany(id: 'water_19', nameAr: 'شركة مياه الشرب والصرف الصحي بمطروح', nameEn: 'Matrouh Water and Wastewater Company'),
  UtilityCompany(id: 'water_20', nameAr: 'شركة مياه الشرب والصرف الصحي بأسيوط والوادي الجديد', nameEn: 'Assiut and New Valley Water and Wastewater Company'),
  UtilityCompany(id: 'water_21', nameAr: 'شركة مياه الشرب والصرف الصحي بشمال وجنوب سيناء', nameEn: 'North and South Sinai Water and Wastewater Company'),
  UtilityCompany(id: 'water_22', nameAr: 'شركة مياه الشرب والصرف الصحي بسوهاج', nameEn: 'Sohag Water and Wastewater Company'),
  UtilityCompany(id: 'water_23', nameAr: 'شركة مياه الشرب والصرف الصحي بالبحر الأحمر', nameEn: 'Red Sea Water and Wastewater Company'),
  UtilityCompany(id: 'water_24', nameAr: 'شركة مياه الشرب والصرف الصحي بالقليوبية', nameEn: 'Qalyubia Water and Wastewater Company'),
  UtilityCompany(id: 'water_25', nameAr: 'شركة مياه الشرب والصرف الصحي بمحافظات القناة', nameEn: 'Canal Governorates Water and Wastewater Company'),
];

const List<UtilityCompany> gasCompanies = [
  UtilityCompany(id: 'gas_1', nameAr: 'الشركة المصرية القابضة للغازات الطبيعية «إيجاس»', nameEn: 'EGAS'),
  UtilityCompany(id: 'gas_2', nameAr: 'الشركة المصرية للغازات الطبيعية «جاسكو»', nameEn: 'GASCO'),
  UtilityCompany(id: 'gas_3', nameAr: 'المصرية لتوزيع الغاز الطبيعي للمدن «تاون جاس»', nameEn: 'Town Gas'),
  UtilityCompany(id: 'gas_4', nameAr: 'شركة غاز مصر', nameEn: 'Egypt Gas'),
  UtilityCompany(id: 'gas_5', nameAr: 'الشركة الحديثة للغاز', nameEn: 'Modern Gas'),
  UtilityCompany(id: 'gas_6', nameAr: 'شركة ترانس جاس', nameEn: 'Trans Gas'),
  UtilityCompany(id: 'gas_7', nameAr: 'شركة الغاز والطاقة «طاقة غاز»', nameEn: 'TAQA Gas'),
  UtilityCompany(id: 'gas_8', nameAr: 'شركة النوبارية للغاز', nameEn: 'Nubaria Gas'),
  UtilityCompany(id: 'gas_9', nameAr: 'شركة الفيوم للغاز', nameEn: 'Fayoum Gas'),
  UtilityCompany(id: 'gas_10', nameAr: 'الشركة الوطنية للغاز «ناتجاس»', nameEn: 'Natgas'),
  UtilityCompany(id: 'gas_11', nameAr: 'شركة مايا جاس', nameEn: 'Maya Gas'),
  UtilityCompany(id: 'gas_12', nameAr: 'شركة أوفرسيز', nameEn: 'Overseas'),
  UtilityCompany(id: 'gas_13', nameAr: 'الشركة المصرية للخدمات الفنية وصيانة الأجهزة «صيانكو»', nameEn: 'SIANCO'),
];

List<UtilityCompany> getCompaniesForSector(String sector) {
  switch (sector.toLowerCase()) {
    case 'electricity':
      return electricityCompanies;
    case 'water':
      return waterCompanies;
    case 'gas':
      return gasCompanies;
    default:
      return [];
  }
}
