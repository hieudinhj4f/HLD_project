import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Giả sử bạn có file định nghĩa màu sắc
// import 'package:hld_project/core/theme/colors.dart';
// Nếu không, tôi sẽ định nghĩa màu trực tiếp
const Color adminPrimaryGreen = Color(0xFF90D2B0);
const Color adminCardBackground = Colors.white;
const Color adminChipGreen = Color(0xFFC8E6C9); // Màu xanh lá nhạt
const Color adminChipRed = Color(0xFFFFCDD2); // Màu đỏ nhạt
const Color adminTextGreen = Color(0xFF2E7D32);
const Color adminTextRed = Color(0xFFC62828);

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Để nội dung "tràn" lên trên, ta không cần AppBar
      // Thay vào đó dùng SafeArea để đảm bảo nội dung không bị tai thỏ che
      backgroundColor: Colors.grey[50], // Màu nền xám rất nhạt
      body: SafeArea(
        bottom: false, // Không cần safe area ở dưới vì đã có AppShell
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Logo HLD
              const Text(
                'HLD',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: adminPrimaryGreen,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 24),

              // 2. Lưới 4 thẻ KPI
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.25, // Tỷ lệ chiều rộng/chiều cao của thẻ
                children: [
                  _KpiCard(
                    title: 'Total Products',
                    value: '236',
                    backgroundColor: adminPrimaryGreen,
                    textColor: Colors.white,
                  ),
                  _KpiCard(
                    title: 'Items Sold',
                    value: '22',
                    backgroundColor: adminCardBackground,
                    textColor: Colors.black,
                  ),
                  _KpiCard(
                    title: 'Today Revenue',
                    value: '1M2',
                    backgroundColor: adminCardBackground,
                    textColor: Colors.black,
                    changeIndicator: _ChangeChip(
                      value: -2.5,
                    ),
                  ),
                  _KpiCard(
                    title: 'Total Revenue',
                    value: '5M2',
                    backgroundColor: adminCardBackground,
                    textColor: Colors.black,
                    changeIndicator: _ChangeChip(
                      value: 3.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Tiêu đề Biểu đồ và Dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Vendor Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _WeekDropdown(),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Biểu đồ
              Container(
                height: 200, // Chiều cao cố định cho biểu đồ
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const _VendorChart(),
              ),
              const SizedBox(height: 24),

              // 5. Thẻ thông tin Nhà thuốc
              _PharmacyInfoCard(),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET CON CHO CÁC THẺ KPI ---
class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final Color backgroundColor;
  final Color textColor;
  final Widget? changeIndicator;

  const _KpiCard({
    required this.title,
    required this.value,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.changeIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              Icon(Icons.more_horiz, color: textColor.withOpacity(0.8), size: 20),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (changeIndicator != null) ...[
            const SizedBox(height: 8),
            changeIndicator!,
          ],
        ],
      ),
    );
  }
}

// --- WIDGET CON CHO CHIP % TĂNG/GIẢM ---
class _ChangeChip extends StatelessWidget {
  final double value; // Ví dụ: 3.4 hoặc -2.5

  const _ChangeChip({required this.value});

  @override
  Widget build(BuildContext context) {
    final bool isPositive = value > 0;
    final Color chipColor = isPositive ? adminChipGreen : adminChipRed;
    final Color textColor = isPositive ? adminTextGreen : adminTextRed;
    final String prefix = isPositive ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$prefix$value%',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// --- WIDGET CON CHO DROPDOWN "THIS WEEK" ---
class _WeekDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Đây là cách đơn giản để giả lập giao diện dropdown
    // Bạn có thể thay bằng DropdownButton thật nếu muốn
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Text(
            'This week',
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey[700],
            size: 20,
          ),
        ],
      ),
    );
  }
}

// --- WIDGET CON CHO BIỂU ĐỒ ---
class _VendorChart extends StatelessWidget {
  const _VendorChart();

  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả lập dựa trên ảnh
    final List<BarChartGroupData> barGroups = [
      _makeGroupData(0, 190), // M
      _makeGroupData(1, 290), // T
      _makeGroupData(2, 150), // W
      _makeGroupData(3, 230), // Th
      _makeGroupData(4, 250), // F
      _makeGroupData(5, 70),  // S
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 300, // Giá trị Y cao nhất trên biểu đồ
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: _bottomTitles,
              reservedSize: 38,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 100,
              getTitlesWidget: _leftTitles,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 100,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[200]!,
              strokeWidth: 1,
            );
          },
        ),
        barGroups: barGroups,
      ),
    );
  }

  // Helper tạo dữ liệu cột
  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: adminPrimaryGreen,
          width: 20,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }

  // Helper cho tiêu đề trục X (M, T, W...)
  Widget _bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.grey, fontSize: 14);
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'M';
        break;
      case 1:
        text = 'T';
        break;
      case 2:
        text = 'W';
        break;
      case 3:
        text = 'Th';
        break;
      case 4:
        text = 'F';
        break;
      case 5:
        text = 'S';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(meta: meta, child: Text(text, style: style));
  }

  // Helper cho tiêu đề trục Y (100, 200...)
  Widget _leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.grey, fontSize: 12);
    String text;
    if (value == 0) {
      text = '0';
    } else if (value == 100) {
      text = '100';
    } else if (value == 200) {
      text = '200';
    } else if (value == 300) {
      text = '300';
    } else {
      return Container();
    }
    return SideTitleWidget(meta: meta, child: Text(text, style: style));
  }
}

// --- WIDGET CON CHO THẺ THÔNG TIN NHÀ THUỐC ---
class _PharmacyInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ảnh nhà thuốc
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            // NHỚ: Thêm ảnh này vào assets/images/pharmacy_image.png
            // và cập nhật file pubspec.yaml
            child: Image.asset(
              'assets/images/pharmacy_image.png', // <-- THAY ĐƯỜNG DẪN NÀY
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          // Thông tin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "KIM ANH'S PHARMACY",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'State:',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: adminChipGreen,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Current Working',
                        style: TextStyle(
                          color: adminTextGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Staff:',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '20 persons',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}