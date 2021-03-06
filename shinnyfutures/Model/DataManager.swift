//
//  DataManager.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/19.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import Foundation
import SwiftyJSON

class DataManager {
    private static let instance: DataManager = {
        let dataManager = DataManager()
        return dataManager
    }()

    private init() {}

    class func getInstance() -> DataManager {
        return instance
    }

    var sSearchHistoryEntities = [String: Search]()
    var sSearchEntities = [String: Search]()
    var sQuotes = [[(key: String, value: JSON)]]()
    var sInsListNames = [[(key: String, value: String)]]()

    //////////////////////////////////////////////////////////////
    var sRtnMD = JSON()
    var sRtnBrokers = JSON()
    var sRtnLogin = JSON()
    var sRtnTD = JSON()
    var sMobileConfirmSettlement = JSON()
    var sPreInsList = ""
    var sInstrumentId = ""
    var sIsLogin = false
    var sUser_id = ""
    //进入登陆页的来源
    var sToLoginTarget = ""

    func parseLatestFile() {
        NSLog("解析开始")
        var sOptionalQuotes = [String: JSON]()
        var sMainQuotes = [String: JSON]()
        var sMainInsListNameNav = [String: String]()
        var sShangqiQuotes = [String: JSON]()
        var sShangqiInsListNameNav = [String: String]()
        var sDalianQuotes = [String: JSON]()
        var sDalianInsListNameNav = [String: String]()
        var sZhengzhouQuotes = [String: JSON]()
        var sZhengzhouInsListNameNav = [String: String]()
        var sZhongjinQuotes = [String: JSON]()
        var sZhongjinInsListNameNav = [String: String]()
        var sNengyuanQuotes = [String: JSON]()
        var sNengyuanInsListNameNav = [String: String]()
        var sDalianzuheQuotes = [String: JSON]()
        var sDalianzuheInsListNameNav = [String: String]()
        var sZhengzhouzeheQuotes = [String: JSON]()
        var sZhengzhouzeheInsListNameNav = [String: String]()
        let latestString = FileUtils.readLatestFile()
        if let latestData = latestString?.data(using: .utf8) {
            do {
                guard let latestJson = try JSONSerialization.jsonObject(with: latestData, options: []) as? [String: Any] else { return }
                for (instrument_id, value) in latestJson {
                    let subJson = value as! [String: Any]
                    let classN = subJson["class"] as! String
                    if !"FUTURE_CONT".elementsEqual(classN) && !"FUTURE".elementsEqual(classN) && !"FUTURE_COMBINE".elementsEqual(classN){continue}
                    let ins_name = subJson["ins_name"] as! String
                    let expired = subJson["expired"] as! Bool
                    let exchange_id = subJson["exchange_id"] as! String
                    let price_tick = (subJson["price_tick"] as! NSNumber).stringValue
                    let volume_multiple = (subJson["volume_multiple"] as! NSNumber).stringValue
                    let sort_key = (subJson["sort_key"] as! NSNumber).intValue

                    let searchEntity = Search(instrument_id: instrument_id, instrument_name: ins_name, exchange_name: "", exchange_id: exchange_id, py: "", p_tick: price_tick, vm: volume_multiple, sort_key: sort_key, margin: 0, underlying_symbol: "")

                    if "FUTURE_CONT".elementsEqual(classN){
                        let py = subJson["py"] as! String
                        searchEntity.py = py
                        let underlying_symbol = subJson["underlying_symbol"] as! String
                        if "".elementsEqual(underlying_symbol){continue}
                        searchEntity.underlying_symbol = underlying_symbol
                        sMainQuotes[instrument_id] = JSON(parseJSON: "{\"instrument_id\":\"\(instrument_id)\", \"instrument_name\":\"\(ins_name)\"}")
                        sMainInsListNameNav[ins_name.replacingOccurrences(of: "主连", with: "")] = instrument_id
                    }

                    if "FUTURE".elementsEqual(classN){
                        let product_short_name = subJson["product_short_name"] as! String
                        let py = subJson["py"] as! String
                        let margin = (subJson["margin"] as! NSNumber).intValue
                        searchEntity.py = py
                        searchEntity.margin = margin
                        switch exchange_id {
                        case "SHFE":
                            if !expired{
                                sShangqiQuotes[instrument_id] = JSON(parseJSON: "{\"instrument_id\":\"\(instrument_id)\", \"instrument_name\":\"\(ins_name)\"}")
                                sShangqiInsListNameNav[product_short_name] = instrument_id
                            }
                            searchEntity.exchange_name = "上海期货交易所"
                        case "CZCE":
                            if !expired{
                                sZhengzhouQuotes[instrument_id] = JSON(parseJSON: "{\"instrument_id\":\"\(instrument_id)\", \"instrument_name\":\"\(ins_name)\"}")
                                sZhengzhouInsListNameNav[product_short_name] = instrument_id
                            }
                            searchEntity.exchange_name = "郑州商品交易所"
                        case "DCE":
                            if !expired {
                                sDalianQuotes[instrument_id] = JSON(parseJSON: "{\"instrument_id\":\"\(instrument_id)\", \"instrument_name\":\"\(ins_name)\"}")
                                sDalianInsListNameNav[product_short_name] = instrument_id
                            }
                            searchEntity.exchange_name = "大连商品交易所"
                        case "CFFEX":
                            if !expired {
                                sZhongjinQuotes[instrument_id] = JSON(parseJSON: "{\"instrument_id\":\"\(instrument_id)\", \"instrument_name\":\"\(ins_name)\"}")
                                sZhongjinInsListNameNav[product_short_name] = instrument_id
                            }
                            searchEntity.exchange_name = "中国金融期货交易所"
                        case "INE":
                            if !expired{
                                sNengyuanQuotes[instrument_id] = JSON(parseJSON: "{\"instrument_id\":\"\(instrument_id)\", \"instrument_name\":\"\(ins_name)\"}")
                                sNengyuanInsListNameNav[product_short_name] = instrument_id
                            }
                            searchEntity.exchange_name = "上海国际能源交易中心"
                        default:
                            return
                        }
                    }

                    if "FUTURE_COMBINE".elementsEqual(classN){
                        let leg1_symbol = subJson["leg1_symbol"] as! String
                        let subJsonFuture = latestJson[leg1_symbol] as! [String: Any]
                        let product_short_name = subJsonFuture["product_short_name"] as! String
                        let py = subJsonFuture["py"] as! String
                        searchEntity.py = py
                        switch exchange_id {
                        case "CZCE":
                            if !expired{
                                sZhengzhouzeheQuotes[instrument_id] = JSON(parseJSON: "{\"instrument_id\":\"\(instrument_id)\", \"instrument_name\":\"\(ins_name)\"}")
                                sZhengzhouzeheInsListNameNav[product_short_name] = instrument_id
                            }
                            searchEntity.exchange_name = "郑州商品交易所"
                        case "DCE":
                            if !expired{
                                sDalianzuheQuotes[instrument_id] = JSON(parseJSON: "{\"instrument_id\":\"\(instrument_id)\", \"instrument_name\":\"\(ins_name)\"}")
                                sDalianzuheInsListNameNav[product_short_name] = instrument_id
                            }
                            searchEntity.exchange_name = "大连商品交易所"
                        default:
                            return
                        }
                    }
                    sSearchEntities[instrument_id] = searchEntity
                }

                //考虑到合约下架或合约列表中不存在，自选合约自建loop，反映到自选列表上让用户删除
                for ins in FileUtils.getOptional() {
                    if let ins_name = sSearchEntities[ins]?.instrument_name {
                        sOptionalQuotes[ins] = JSON(parseJSON: "{\"instrument_id\":\"\(ins)\", \"instrument_name\":\"\(ins_name)\"}")
                    }else{
                        sOptionalQuotes[ins] = JSON(parseJSON: "{\"instrument_id\":\"\(ins)\", \"instrument_name\":\"\(ins)\"}")
                    }
                }

                sQuotes.append(sortByKey(insList: sOptionalQuotes))
                sQuotes.append(sortByKey(insList: sMainQuotes))
                sQuotes.append(sortByKey(insList: sShangqiQuotes))
                sQuotes.append(sortByKey(insList: sNengyuanQuotes))
                sQuotes.append(sortByKey(insList: sDalianQuotes))
                sQuotes.append(sortByKey(insList: sZhengzhouQuotes))
                sQuotes.append(sortByKey(insList: sZhongjinQuotes))
                sQuotes.append(sortByKey(insList: sDalianzuheQuotes))
                sQuotes.append(sortByKey(insList: sZhengzhouzeheQuotes))

                sInsListNames.append([(key: String, value: String)]())
                sInsListNames.append(sortByValue(insList: sMainInsListNameNav))
                sInsListNames.append(sortByValue(insList: sShangqiInsListNameNav))
                sInsListNames.append(sortByValue(insList: sNengyuanInsListNameNav))
                sInsListNames.append(sortByValue(insList: sDalianInsListNameNav))
                sInsListNames.append(sortByValue(insList: sZhengzhouInsListNameNav))
                sInsListNames.append(sortByValue(insList: sZhongjinInsListNameNav))
                sInsListNames.append(sortByValue(insList: sDalianzuheInsListNameNav))
                sInsListNames.append(sortByValue(insList: sZhengzhouzeheInsListNameNav))

                
            } catch {
                print(error.localizedDescription)
            }
        }
        NSLog("解析结束")
    }

    func sortByKey(insList: [String: JSON]) -> [(key: String, value: JSON)] {
        return insList.sorted(by: {
            if let sortKey0 = (sSearchEntities[$0.key]?.sort_key), let sortKey1 = (sSearchEntities[$1.key]?.sort_key){
                if sortKey0 != sortKey1{
                    return sortKey0 < sortKey1
                }else{
                    return $0.key < $1.key
                }
            }
            return $0.key < $1.key
        })
    }

    func sortByValue(insList: [String: String]) -> [(key: String, value: String)] {
        return insList.sorted(by: {
            if let sortKey0 = (sSearchEntities[$0.value]?.sort_key), let sortKey1 = (sSearchEntities[$1.value]?.sort_key){
                if sortKey0 != sortKey1{
                    return sortKey0 < sortKey1
                }else{
                    return $0.value < $1.value
                }
            }
            return $0.value < $1.value
        })
    }

    func saveOrRemoveIns(ins: String) {
        var optional = FileUtils.getOptional()
        if !optional.contains(ins) {
            optional.append(ins)
            FileUtils.saveOptional(ins: optional)
            var quote: JSON!
            if let ins_name = sSearchEntities[ins]?.instrument_name {
                quote = JSON(parseJSON: "{\"instrument_id\":\"\(ins)\", \"instrument_name\":\"\(ins_name)\"}")
            }else{
                quote = JSON(parseJSON: "{\"instrument_id\":\"\(ins)\", \"instrument_name\":\"\(ins)\"}")
            }
            sQuotes[0].append((key: ins, value: quote))
            ToastUtils.showPositiveMessage(message: "合约\(ins)已添加到自选～")
        } else if let index = optional.index(of: ins), let index1 = sQuotes[0].index(where: {$0.key.elementsEqual(ins)}){
            optional.remove(at: index)
            FileUtils.saveOptional(ins: optional)
            //如果三个数据集之间不同步,删除会有崩溃的危险
            sQuotes[0].remove(at: index1)
            ToastUtils.showNegativeMessage(message: "合约\(ins)被踢出自选～")
        }
        NotificationCenter.default.post(name: Notification.Name(CommonConstants.RefreshOptionalInsListNotification), object: nil)
    }

    func saveDecimalByPtick(decimal: Int, data: String) -> String {
        guard let num = Double(data) else {return data}
        return String(format: "%.\(decimal)f", num)
    }

    func getDecimalByPtick(instrumentId: String) -> Int {
        if let search = sSearchEntities[instrumentId] {
            let ptick = search.p_tick
            if ptick.contains("."), let index = ptick.index(of: ".")?.encodedOffset {
                let decimal = ptick.count - index - 1
                return decimal
            } else {
                return 0
            }
        }
        return 0
    }

    func parseRtnMD(rtnData: JSON) {
        do {
            let dataArray = rtnData[RtnMDConstants.data].arrayValue
            for dataJson in dataArray {
                try sRtnMD.merge(with: dataJson)
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(CommonConstants.RtnMDNotification), object: nil)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func parseBrokers(brokers: JSON) {
        do {
            try sRtnBrokers.merge(with: brokers)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(CommonConstants.BrokerInfoNotification), object: nil)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func parseRtnTD(transactionData: JSON) {
        do {
            let dataArray = transactionData[RtnTDConstants.data].arrayValue
            for dataJson in dataArray {
                let tradeJson = dataJson[RtnTDConstants.trade]
                if !tradeJson.isEmpty {
                    try sRtnTD.merge(with: tradeJson)
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name(CommonConstants.RtnTDNotification), object: nil)
                    }
                }

                if !sIsLogin{
                    let session = tradeJson[sUser_id][RtnTDConstants.session]
                    if !session.isEmpty {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name(CommonConstants.LoginNotification), object: nil)
                        }
                    }
                }

                let notifyArray = dataJson[RtnTDConstants.notify]
                if !notifyArray.isEmpty {
                    for (_, notifyJson) in notifyArray.dictionaryValue {
                        let content = notifyJson[NotifyConstants.content].stringValue
                        let type = notifyJson[NotifyConstants.type].stringValue
                        if "SETTLEMENT".elementsEqual(type){
                            DispatchQueue.main.async {
                                ConfirmSettlementView.getInstance().showConfirmSettlement(message: content)
                            }
                        }else{
                            DispatchQueue.main.async {
                                ToastUtils.showPositiveMessage(message: content)
                            }
                        }

                    }
                    
                }
            }

        } catch {
            print(error.localizedDescription)
        }
    }

}
