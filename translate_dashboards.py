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
    "Car": "车辆",
    "Custom Battery Capacity (kWh) when new": "新车时自定义电池容量 (kWh)",
    "Custom Max Range when new": "新车时自定义最大续航",
    "Bucket Width": "桶宽度",
    "Include Moving Average / Percentiles": "包含移动平均/百分位数",
    "Moving Average / Percentiles Width": "移动平均/百分位宽度",
    "Geofence": "地理围栏",
    "Location": "位置",
    "Type": "类型",
    "Cost >=" : "费用 >=",
    "Duration (minutes) >=" : "持续时间(分钟) >=",
    "Exclude locations": "排除位置",
    "temperature unit": "温度单位",
    "length unit": "长度单位",
    "min. distance per drive": "最小行驶距离",
    "Address": "地址",
    "Time Resolution": "时间分辨率",
    "Action": "操作",
    "Address Filter": "地址筛选",
    "Period": "周期",
    "High Precision": "高精度",
    "min. Idle Time (h)": "最小空闲时间(小时)",
    "Max range (new)": "最大续航(新)",
    "Max range (now)": "最大续航(现)",
    "Range lost": "续航衰减",
    "Efficiency": "能效",
    "Energy added": "补充能量",
    "Energy used": "能耗",
    "Energy drained": "耗电量",
    "Cost": "费用",
    "Location": "位置",
    "Distance": "距离",
    "Temp": "温度",
    "Range": "续航",
    "SOC": "电池电量 (SOC)",
    "Odometer": "里程表",
    "Outside Temperature": "车外温度",
    "Inside Temperature": "车内温度",
    "Driver Temperature": "驾驶员温度",
    "Passenger Temperature": "乘客温度",
    "Climate": "空调系统",
    "Fan status": "风扇状态",
    "Neighbourhood": "街区",
    "State": "州/省",
    "Country": "国家",
    "Address": "地址",
    "Updated at": "更新时间",
    "Duration": "持续时间",
    "Start": "开始",
    "End": "结束",
    "Start Address": "出发地址",
    "End Address": "目的地地址",
    "ID": "编号",
    "Date": "日期",
    "Installed Version": "已安装版本",
    "Since Previous Update": "自上次更新以来",
    "Range Diff": "续航差异",
    "Range (ideal)": "理想续航",
    "Range (rated)": "额定续航",
    "Range (est.)": "估计续航",
    "Ø Speed": "平均速度",
    "Ø Temp": "平均温度",
    "Ø Power": "平均功率",
    "Ø Consumption (net)": "平均能耗(净)",
    "Ø Consumption (gross)": "平均能耗(总)",
    "Ø Range loss / h": "每小时续航损失",
    "Ø Ideal range": "平均理想续航",
    "Ø Rated range": "平均额定续航",
    "Mileage": "里程",
    "Energy": "能量",
    # 还可以补充更多
}

# 2. 可以汉化的字段列表
target_fields = ["title", "label", "name", "value"]

# 3. 分类 tags
file_tags = {
    "battery-health.json": ["battery"],
    "charge-level.json": ["battery"],
    "charges.json": ["battery"],
    "charging-stats.json": ["battery"],
    "database-info.json": ["system"],
    "drive-stats.json": ["trip"],
    "drives.json": ["trip"],
    "efficiency.json": ["trip"],
    "locations.json": ["location"],
    "mileage.json": ["trip"],
    "overview.json": ["tesla"],
    "projected-range.json": ["battery"],
    "states.json": ["trip"],
    "statistics.json": ["trip"],
    "timeline.json": ["trip"],
    "trip.json": ["trip"],
    "updates.json": ["system"],
    "vampire-drain.json": ["battery"],
    "visited.json": ["location"],
    "internal/charge-details.json": ["battery"],
    "internal/drive-details.json": ["trip"],
    "internal/home.json": ["tesla"],
    "reports/dutch-tax.json": ["trip"],
}

# 4. 要跳过的 value 类型（单位、内部标识）
skip_values = {
    "km", "mi", "Wh/km", "Wh/mi", "percentunit", "velocitykmh", "velocitymph",
    "lengthkm", "lengthmi", "lengthm", "lengthft", "pressurebar", "pressurepsi",
    "dateTimeAsLocal", "percent", "amp", "kwatt", "kwatth", "bytes", "watt",
    "bool_on_off", "hidden", "none", "right", "left", "center",
    "celsius", "fahrenheit", "lines", "dtdurations", "auto", "time: YYYY-MM-DD HH:mm:ss"
}

# 5. 输入输出路径
dashboard_dir = "grafana/dashboards"
output_dir = "output_dashboards"
os.makedirs(output_dir, exist_ok=True)

# 6. 翻译函数
def translate_text(text, field=None):
    if field == "value" and text in skip_values:
        return text
    return translations.get(text, text)

# 7. 递归处理函数
def translate_obj(obj):
    if isinstance(obj, dict):
        for key in list(obj.keys()):
            if key in target_fields and isinstance(obj[key], str):
                obj[key] = translate_text(obj[key], field=key)
            translate_obj(obj[key])
    elif isinstance(obj, list):
        for item in obj:
            translate_obj(item)

# 8. 遍历处理文件
for root, dirs, files in os.walk(dashboard_dir):
    for filename in files:
        if filename.endswith(".json"):
            path = os.path.join(root, filename)
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)

            # 替换 basemap 地图瓦片
            if "panels" in data:
                for panel in data["panels"]:
                    if panel.get("type") == "geomap" and "basemap" in panel:
                        panel["basemap"] = {
                            "config": {
                                "url": "https://tile.dhuar.com/{z}/{x}/{y}.png"
                            },
                            "name": "自定义地图",
                            "type": "xyz"
                        }

            # 替换 links
            data["links"] = [
                {
                    "asDropdown": True,
                    "icon": "external link",
                    "tags": ["tesla"],
                    "title": "车辆信息",
                    "type": "dashboards"
                },
                {
                    "asDropdown": True,
                    "icon": "external link",
                    "includeVars": False,
                    "keepTime": False,
                    "tags": ["battery"],
                    "targetBlank": False,
                    "title": "电池",
                    "tooltip": "",
                    "type": "dashboards",
                    "url": ""
                },
                {
                    "asDropdown": True,
                    "icon": "external link",
                    "includeVars": False,
                    "keepTime": False,
                    "tags": ["trip"],
                    "targetBlank": False,
                    "title": "行驶",
                    "tooltip": "",
                    "type": "dashboards",
                    "url": ""
                }
            ]

            # 补充 tags 分类
            relative_path = os.path.relpath(path, dashboard_dir).replace("\\", "/")
            tags = file_tags.get(relative_path, [])
            if tags:
                data["tags"] = tags

            # 汉化内容
            translate_obj(data)

            # 保存
            output_path = os.path.join(output_dir, relative_path)
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            with open(output_path, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False, indent=2)

            print(f"✅ 已处理: {relative_path}")

print("\n✅✅✅ 全部完成！在 output_dashboards/ 查看汉化后的仪表盘！")

