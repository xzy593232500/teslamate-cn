import os
import json

# 完整翻译对照表，基于你提供的 title
translations = {
    "TeslaMate": "特斯拉伴侣",
    "Dashboards": "仪表盘",
    "Battery Capacity": "电池容量",
    "Ranges [$preferred_range]": "续航范围 [$preferred_range]",
    "Drive Stats": "行驶统计",
    "AC/DC - Energy Used": "交流/直流 - 能耗",
    "Estimated Degradation": "预计电池衰减",
    "Battery Health": "电池健康状况",
    "Charging Stats": "充电统计",
    "Current SOC": "当前电量 (SOC)",
    "Efficiency": "能耗效率",
    "Current Stored Energy": "当前储存能量",
    "Battery Capacity by Mileage": "按里程统计电池容量",
    "Charge Level": "充电电量",
    "Summary of this period": "本周期概览",
    "View charge details": "查看充电详情",
    "Set Cost": "设置费用",
    "Create or edit geo-fence": "创建或编辑地理围栏",
    "Charger type: $charge_type": "充电器类型: $charge_type",
    "General information (All charges)": "通用信息 (所有充电记录)",
    "Incomplete Charges 🪫": "未完成的充电 🪫",
    "Charges": "充电记录",
    "# of Charges": "充电次数",
    "Total Energy added": "总能量添加",
    "SuC Charging Cost": "超级充电费用",
    "Total Charging Cost": "充电总费用",
    "Ø Cost per 100 $length_unit": "每100$length_unit平均花费",
    "Ø Cost per kWh": "每kWh平均费用",
    "Ø Cost per kWh DC": "每kWh直流费用",
    "Ø Cost per kWh AC": "每kWh交流费用",
    "Charge Heatmap": "充电热力图",
    "Charge Delta": "充电变化量",
    "Charging heat map by kWh": "按kWh显示充电热力图",
    "AC/DC - Duration": "交流/直流 - 时间",
    "Show charge details": "查看充电详情",
    "DC Charging Curve": "直流充电曲线",
    "Charge Stats": "充电统计数据",
    "Discharge Stats": "放电统计数据",
    "Top Charging Stations (Charged)": "热门充电站（充电量）",
    "Top Charging Stations (Cost)": "热门充电站（花费）",
    "Database Information": "数据库信息",
    "Mileage": "里程",
    "Stats": "统计数据",
    "Software": "软件版本",
    "Incomplete Data": "不完整数据",
    "PostgreSQL Version": "PostgreSQL版本",
    "Indexes": "索引",
    "Database Total Size": "数据库总大小",
    "Timezone": "时区",
    "Statistics of SQL planning and execution": "SQL执行与规划统计",
    "Time at which all statistics in the pg_stat_statements view were last reset": "pg_stat_statements统计最后重置时间",
    "Number of Statements tracked via pg_stat_statements": "pg_stat_statements跟踪的语句数",
    "About pg_stat_statements (track statistics of SQL planning and execution)": "关于pg_stat_statements (追踪SQL计划与执行统计)",
    "Top 20 Statements (by mean time spent executing the statement)": "执行平均时间排名前20的SQL",
    "Top 20 Statements (by total time spent executing the statement)": "执行总时间排名前20的SQL",
    "# of Drives": "行驶次数",
    "Total Distance logged": "记录总里程",
    "Total Energy consumed (net)": "总能量消耗 (净值)",
    "Median distance of a drive": "行驶中位距离",
    "Ø Distance driven per day": "日均行驶里程",
    "Ø Energy consumed (net) per day": "日均能耗(净)",
    "Max Speed": "最大速度",
    "Speed Histogram ($speed_unit)": "速度直方图($speed_unit)",
    "Extrapolated monthly mileage": "推算月行驶里程",
    "Extrapolated annual mileage": "推算年行驶里程",
    "Top 10 Destinations (in this period)": "本期热门目的地Top10",
    "Drive": "单次行驶",
    "General information (All drives)": "所有行驶记录概况",
    "Incomplete Drives 🛣️": "未完成行驶 🛣️",
    "Ø Consumption (net)": "平均能耗 (净值)",
    "Ø Consumption (gross)": "平均能耗 (总值)",
    "Logged Distance": "记录距离",
    "Temperature – Driving Efficiency": "温度 - 行驶效率",
    "Current $preferred_range efficiency": "当前$preferred_range效率",
    "Derived ideal efficiencies": "推导理想效率",
    "Derived rated efficiencies": "推导额定效率",
    "Locations": "位置",
    "Cities": "城市",
    "States": "州/省份",
    "Countries": "国家",
    "Last visited": "最后访问",
    "Addresses": "地址",
    "Geo-fences": "地理围栏",
    "Overview": "总览",
    "Battery Level": "电池电量",
    "Charging Voltage": "充电电压",
    "Charging Power": "充电功率",
    "Charge Level": "充电电量",
    "Range": "续航里程",
    "Updates": "更新",
    "Firmware": "固件版本",
    "Odometer": "总里程",
    "Charging Details": "充电详情",
    "Driver Temp": "驾驶员温度",
    "Outside Temp": "外部温度",
    "Inside Temp": "车内温度",
    "Projected Range - Mileage": "预计续航 - 里程",
    "Projected Range - Battery Level": "预计续航 - 电量",
    "Projected Range - Outdoor Temp": "预计续航 - 外部温度",
    "Statistics": "统计信息",
    "Trip": "行程",
    "Time spent": "花费时间",
    "Slot details": "时间槽详情",
    "Timeline": "时间轴",
    "Vampire Drain": "电池自放电",
    "Visited": "已访问地点",
    "Drives - Dutch tax": "行驶记录 - 荷兰税务版",
    "Charge Details": "充电详情",
    "Cost": "费用",
    "Charge Energy": "充电能量",
    "Ø Power": "平均功率",
    "Ø Outdoor Temperature": "平均外部温度",
    "Ranges ($preferred_range)": "续航范围($preferred_range)",
    "Charging curve": "充电曲线",
    "Drive Details": "行驶详情",
    "Elevation": "海拔高度",
    "Temperatures": "温度",
    "Tire Pressure": "胎压",
    "More Details": "更多细节",
    "Odometer (From - To)": "里程表(起-止)",
    "Drive Duration": "行驶时间",
    "Selected Duration": "选定时长",
    "Distance driven": "行驶距离",
    "Elevation Summary": "海拔变化总结",
    "Energy consumed (net)": "能量消耗(净值)",
    "Energy recovered": "能量回收",
    "Consumption (net)": "能耗(净值)",
    "Ø Speed": "平均速度",
    "Home": "主页",
}

# 需要处理的字段
target_fields = ["title"]

# 输入和输出目录
dashboard_dir = "grafana/dashboards"
output_dir = "output_dashboards"
os.makedirs(output_dir, exist_ok=True)

# 处理函数
def translate_text(text):
    return translations.get(text, text)

# 遍历 dashboards 目录下所有 json 文件
for root, dirs, files in os.walk(dashboard_dir):
    for filename in files:
        if filename.endswith(".json"):
            path = os.path.join(root, filename)
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)

            # 递归替换 title 和 label，同时修改 basemap
            def translate_obj(obj):
                if isinstance(obj, dict):
                    for key in obj:
                        if key in target_fields and isinstance(obj[key], str):
                            obj[key] = translate_text(obj[key])
                        elif key == "basemap" and isinstance(obj[key], dict):
                            obj[key] = {
                                "config": {
                                    "url": "https://tile.dhuar.com/{z}/{x}/{y}.png"
                                },
                                "name": "Custom Layer",
                                "type": "xyz"
                            }
                        else:
                            translate_obj(obj[key])
                elif isinstance(obj, list):
                    for item in obj:
                        translate_obj(item)

            translate_obj(data)

            # 保存汉化并修改 basemap 后的文件
            relative_path = os.path.relpath(path, dashboard_dir)
            output_path = os.path.join(output_dir, relative_path)
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            with open(output_path, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False, indent=2)

            print(f"已处理: {relative_path}")

print("\n✅ 全部完成！请在 output_dashboards/ 目录查看汉化+换瓦片后的仪表盘文件。")


