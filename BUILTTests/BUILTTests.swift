import Testing

@testable import BUILT

@Suite("BUILT Test Infrastructure")
struct BUILTTestInfrastructureTests {
    @Test(
        "The test bundle can load the BUILT app module"
    )
    func appModuleLoads() {
        #expect(
            FitnessIdentity.allCases.count
            == 4
        )

        #expect(
            !FitnessIdentity
                .buildingConsistency
                .identityStatement
                .isEmpty
        )
    }
}
