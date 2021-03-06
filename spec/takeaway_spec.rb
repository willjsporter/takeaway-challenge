require 'takeaway'

describe Takeaway do
  let(:menu1) { double :Menu }
  let(:restaurant1) { double :Restaurant }
  let(:takeaway1) { described_class.new(restaurant1, "07767890000") }
  # number changed as this will be publicly commited by was tested first
  let(:texty) { double :Texting }

  context "Initializes" do

    it "won't initialize without a restaurant and a number parameter" do
      expect { described_class.new }.to raise_error
    end

    it 'initializes with a restaurant and a user phone number' do
      criteria1 = takeaway1.restaurant == restaurant1
      criteria2 = takeaway1.phone_no == 447_767_890_000
      expect(criteria1 && criteria2).to eq true
    end

  end

  context "reads menu" do

    it "calls read menu on restaurant's menu" do
      expect(restaurant1).to receive(:display_menu)
      takeaway1.read_menu
    end

  end

  context "chooses dishes" do

    it "select_dish takes two parameters (the quantity is defaulted to 1)" do
      expect { takeaway1.select_dish }.to raise_error
    end

    it "allows customers to add dishes to the basket" do
      expect { takeaway1.select_dish("kebab") }.to change { takeaway1.order.length }.by 1
    end

    it " adds selected items as a list of individual dishes (with repetition if necessary)" do
      takeaway1.select_dish("kebab")
      takeaway1.select_dish("kebab", 2)
      criteria1 = takeaway1.order[0] == "kebab"
      criteria2 = takeaway1.order[1] == "kebab"
      criteria3 = takeaway1.order[2] == "kebab"
      expect(criteria1 && criteria2 && criteria3).to eq true
    end

  end

  context "shows basket" do

    before(:each) do
      takeaway1.select_dish("Kebab")
      allow(restaurant1).to receive(:menu).and_return(menu1)
      allow(menu1).to receive(:list).and_return({ "Kebab" => 5, "Pizza" => 6 })
    end

    it 'accumulates separate orders of the same dish and accumulates dishes' do
      takeaway1.select_dish("Kebab", 2)
      takeaway1.select_dish("Pizza", 1)
      # p takeaway1.restaurant
      # p takeaway1.restaurant.menu
      # p takeaway1.restaurant.menu.list
      message1 = "3x Kebab @ £5 each ------- £15\n" +
      "1x Pizza @ £6 each ------- £6\n" +
      "Total = £21\n"
      expect { takeaway1.show_basket }.to output(message1).to_stdout
    end

  end

  context "checkout" do

    before(:each) do
      allow(texty).to receive(:send_text).and_return(nil)
      takeaway1.texter = texty
      allow(restaurant1).to receive(:menu).and_return(menu1)
      allow(menu1).to receive(:list).and_return({ "Kebab" => 5, "Pizza" => 6 })
    end

    it "won't work if the order is closed" do
      takeaway1.select_dish("Kebab", 2)
      takeaway1.checkout(1234)
      error_mess = "Order now closed"
      expect { takeaway1.checkout }.to raise_error(error_mess)
    end

    it "requires a card no. to pay the bill" do
      expect { takeaway1.checkout }.to raise_error "Payment card details required"
    end

    it "requires some items to be in basket" do
      error_mess1 = "Basket empty - cannot checkout"
      expect { takeaway1.checkout(1234) }.to raise_error(error_mess1)
    end

    it "saves credit card number upon payment to debit amount" do
      takeaway1.select_dish("Kebab", 2)
      takeaway1.checkout(1234)
      expect(takeaway1.payment_card_no).to eq 1234
    end

    it 'provides a summary of the order on checkout' do
      takeaway1.select_dish("Kebab", 2)
      message = "Your final order is:\n" +
      "2x Kebab @ £5 each ------- £10\n" +
      "Total = £10\n"
      expect { takeaway1.checkout(1234) }.to output(message).to_stdout
    end

    it "sends a text upon completion of checkout" do
      takeaway1.select_dish("Kebab", 2)
      expect(texty).to receive(:send_text)
      takeaway1.checkout(1_234_567_890_123_456)
    end

    it 'if checkout has already been completed then no more items can be added' do
      takeaway1.select_dish("Kebab", 2)
      takeaway1.checkout(1234)
      error_mess2 = "Order now closed"
      expect { takeaway1.checkout(4312) }.to raise_error(error_mess2)
    end

  end

  xcontext "accepts orders by text" do

    it "takes a text order and adds items to menu" do

    end

  end

end
