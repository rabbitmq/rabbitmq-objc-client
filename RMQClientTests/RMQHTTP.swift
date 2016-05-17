import Foundation

class RMQHTTP {
    var uri: String

    init(_ uri: String) {
        self.uri = uri
    }

    func get(path: String) -> NSData {
        let url = NSURL(string: uri + path)

        let semaphore = dispatch_semaphore_create(0)

        var data: NSData?
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(d, _, _) in
            data = d
            dispatch_semaphore_signal(semaphore)
        }
        
        task.resume()

        dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(5))

        return data!
    }

    func delete(path: String) -> NSData {
        let url = NSURL(string: "\(uri)\(path)")

        let semaphore = dispatch_semaphore_create(0)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "DELETE"

        var data: NSData?
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (d, _, _) in
            data = d
            dispatch_semaphore_signal(semaphore)
        }

        task.resume()

        dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(5))
        
        return data!
    }
}
