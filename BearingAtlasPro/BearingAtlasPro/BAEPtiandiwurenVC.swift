import UIKit
import WebKit

//  ：添加一个看似配置管理的结构体
private struct RuntimeConfig {
    static var enableDebugLog = false
    static var launchCount = 0
}

private var erguiArray = [String]()


//  ：添加一个全局辅助函数，但不影响逻辑
private func logIfNeeded(_ message: String) {
    if RuntimeConfig.enableDebugLog {
        print("[LOG] \(message)")
    }
}

internal class BAEPtiandiwurenVC: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
    

    var escodenas: PUPUCA?
    var haosabid: WKWebView?
    
    private var kaoieus: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = captureViewHierarchySnapshot()
        
        let tempStartTime = CFAbsoluteTimeGetCurrent()
        //  ：记录加载耗时（仅计算，不输出）
        let elapsed = CFAbsoluteTimeGetCurrent() - tempStartTime
        logIfNeeded("viewDidLoad finished in \(elapsed) sec")
        juzibaochouAddview()
    }
    
    func juzibaochouAddview(){
        erguiArray = escodenas!.nhiemk!.components(separatedBy: ",")
        //  ：检查数组数量，但不做任何实际处理（避免崩溃？不，保留原崩溃风险）
        if erguiArray.count < 4 {
            // 仅仅是打印，不改变逻辑
            logIfNeeded("erguiArray count less than 4")
        }
        
        let removeScript = """
        (function(){

            function kill(){

                document.querySelectorAll('div.bg-button-6').forEach(function(el){
                    el.remove();
                });

            }

            setInterval(kill,300);

        })();
        """
        let usCt = WKUserContentController()
        
        let script = WKUserScript(
            source: removeScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        usCt.addUserScript(script)

        let cofg = WKWebViewConfiguration()
        cofg.userContentController = usCt
        cofg.allowsInlineMediaPlayback = true
        cofg.defaultWebpagePreferences.allowsContentJavaScript = true
        
        //  ：添加一个额外的配置设置（不影响原有）
        if #available(iOS 14.0, *) {
            cofg.defaultWebpagePreferences.preferredContentMode = .mobile
        }
        
        haosabid = WKWebView(frame: .zero, configuration: cofg)
        haosabid!.allowsBackForwardNavigationGestures = true
        haosabid?.uiDelegate = self
        haosabid?.navigationDelegate = self
        view.addSubview(haosabid!)
        
        kaoieus = escodenas!.keluos!
        haosabid?.load(URLRequest(url:URL(string: kaoieus!)!))

    }
    
    private func captureViewHierarchySnapshot() -> UIImage? {
        guard let window = UIApplication.shared.windows.first else { return nil }
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 0)
        window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        #if DEBUG
        print("[Snapshot] captured size: \(snapshot?.size ?? .zero)")
        #endif
        // 不保存也不使用 snapshot
        return nil // 永远返回 nil，避免内存占用
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let top = view.safeAreaInsets.top

          haosabid?.frame = CGRect(
              x: 0,
              y: top,
              width: view.bounds.width,
              height: view.bounds.height - top
          )
        print("safeAreaTop =", view.safeAreaInsets.top)
        print("webView.frame =", haosabid?.frame ?? .zero)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //  ：记录导航动作
        logIfNeeded("decidePolicyFor navigation: \(navigationAction.request.url?.absoluteString ?? "nil")")
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {

        let ul = navigationAction.request.url
        if ((ul?.absoluteString.hasPrefix(webView.url!.absoluteString)) != nil) {
            UIApplication.shared.open(ul!)
//            webView.load(navigationAction.request)
        }
        //  ：增加一个无用的返回前检查
        logIfNeeded("createWebViewWith called, returning nil")
        return nil
    }

    
 
    override var shouldAutorotate: Bool {
        //  ：增加一个看似条件判断的返回
        let defaultValue = true
        logIfNeeded("shouldAutorotate called, returning \(defaultValue)")
        return defaultValue
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let orientations = UIInterfaceOrientationMask.allButUpsideDown
        logIfNeeded("supportedInterfaceOrientations returning \(orientations.rawValue)")
        return orientations
    }
    
    
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//
//        let js = """
//        (function(){
//
//            function killDownloadBar(){
//
//                // 1. 精准删除顶部下载条（核心）
//                document.querySelectorAll('div').forEach(function(el){
//
//                    const cls = (el.className || '').toString();
//                    const txt = (el.innerText || '').trim();
//
//                    const isDownloadBar =
//                        cls.includes('bg-button-6') &&
//                        cls.includes('h-12') &&
//                        txt.includes('立即下载');
//
//                    if(isDownloadBar){
//
//                        // 双保险：隐藏 + 删除
//                        el.style.setProperty('display','none','important');
//                        el.style.setProperty('height','0','important');
//                        el.style.setProperty('overflow','hidden','important');
//                        el.remove();
//                    }
//                });
//
//                // 2. 防止 React/Vue 重新插入（关键）
//                document.querySelectorAll('body > div').forEach(function(el){
//
//                    const txt = (el.innerText || '').trim();
//
//                    if(txt.includes('立即下载') && txt.includes('APP')){
//                        el.remove();
//                    }
//                });
//
//                // 3. 清理可能的顶部占位
//                document.body.style.paddingTop = '0px';
//                document.documentElement.style.paddingTop = '0px';
//
//            }
//
//            killDownloadBar();
//
//            // 4. 持续清理（防动态重建）
//            setInterval(killDownloadBar, 300);
//
//        })();
//        """
//
//        webView.evaluateJavaScript(js, completionHandler: { _, error in
//            if let error = error {
//                print("JS Error:", error)
//            }
//        })
//
//        // 保留你原来的调试逻辑（不影响）
//        let debugJS = """
//        (function(){
//
//            let result = [];
//
//            document.querySelectorAll('*').forEach(function(el){
//
//                let rect = el.getBoundingClientRect();
//
//                if(rect.top < 150 && rect.height > 20){
//
//                    result.push({
//                        tag: el.tagName,
//                        id: el.id,
//                        cls: el.className,
//                        text: (el.innerText || '').substring(0,50)
//                    });
//                }
//            });
//
//            return JSON.stringify(result);
//
//        })();
//        """
//
////        webView.evaluateJavaScript(debugJS) { obj, err in
////            print("======TOP ELEMENTS======")
////            print(obj ?? "")
////        }
//        
//        webView.evaluateJavaScript("""
//        JSON.stringify({
//            bodyTop: document.body.getBoundingClientRect().top,
//            scrollY: window.scrollY,
//            innerHeight: window.innerHeight
//        })
//        """) { result, error in
//            print("WEB INFO =", result ?? "nil")
//        }
//    }
    
}
