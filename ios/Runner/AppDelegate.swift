import UIKit
import Flutter
import workmanager
import BackgroundTasks

@UIApplicationMain

@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      
        UNUserNotificationCenter.current().delegate = self
        GeneratedPluginRegistrant.register(with: self)
          
            if #available(iOS 13.0, *) {

                BGTaskScheduler.shared.register(forTaskWithIdentifier: "oleh.balychev.newtaskbackgroundapp.periodic", using: nil) { task in
                    self.handleAppRefresh(task as! BGAppRefreshTask)
                }
                
                scheduleAppRefresh()
            }

        WorkmanagerPlugin.setPluginRegistrantCallback { registry in
            GeneratedPluginRegistrant.register(with: registry)
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)

    }
    
    @available(iOS 13, *)
     func scheduleAppRefresh() {
       let request = BGAppRefreshTaskRequest(
        identifier: "oleh.balychev.newtaskbackgroundapp.periodic")
       request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
            
       do {
          try BGTaskScheduler.shared.submit(request)
       } catch {
          print("Could not schedule app refresh: \(error)")
       }
    }

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
         completionHandler(.alert) // shows banner even if app is in foreground
     }
    
    @available(iOS 13, *)
    private func handleAppRefresh(_ task: BGTask) {
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 1
            let blockOperation = BlockOperation {
                print("Executing!")
            }
           
            queue.addOperation(blockOperation)

            task.expirationHandler = {
                queue.cancelAllOperations()
            }

            let lastOperation = queue.operations.last
            lastOperation?.completionBlock = {
                task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
            }

        }

}
