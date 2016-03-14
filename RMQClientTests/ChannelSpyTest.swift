import XCTest

class ChannelSpyTest: XCTestCase {
    
    func testObeysContract() {
        let ch = ChannelSpy(1)
        let contract = RMQChannelContract(ch)

        contract.check()
    }
    
}
