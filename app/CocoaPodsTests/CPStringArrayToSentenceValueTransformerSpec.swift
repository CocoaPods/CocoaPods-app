import Quick
import Nimble

class CPStringArrayToSentenceValueTransformerSpec : QuickSpec {
  override func spec() {
    describe("CPStringArrayToSentenceValueTransformer") {
      context("with one item") {
        it("returns the original item") {
          let input = ["This"]
          let transformer = CPStringArrayToSentenceValueTransformer()
          let output = transformer.transformedValue(input) as? String
          expect(output).to(equal("This"))
        }
      }

      context("with two items") {
        it("joins with an ampersand") {
          let input = ["This", "that"]
          let transformer = CPStringArrayToSentenceValueTransformer()
          let output = transformer.transformedValue(input) as? String
          expect(output).to(equal("This & that"))
        }
      }

      context("with three items") {
        it("joins with a comma and ampersand") {
          let input = ["This", "that", "the like"]
          let transformer = CPStringArrayToSentenceValueTransformer()
          let output = transformer.transformedValue(input) as? String
          expect(output).to(equal("This, that & the like"))
        }
      }

      context("with four items") {
        it("joins with commas and ampersand") {
          let input = ["This", "that", "another", "the like"]
          let transformer = CPStringArrayToSentenceValueTransformer()
          let output = transformer.transformedValue(input) as? String
          expect(output).to(equal("This, that, another & the like"))
        }
      }
    }
  }
}
