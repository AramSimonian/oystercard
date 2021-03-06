require './lib/oystercard'

describe Oystercard do

  subject(:oystercard) { described_class.new }
  let(:entry_station) {double(:entry_station)}
  let(:exit_station) {double(:exit_station)}

  let(:minimum_balance) { Oystercard::MINIMUM_BALANCE }
  let(:maximum_balance) { Oystercard::MAXIMUM_BALANCE }
  let(:minimum_fare) { Oystercard::MINIMUM_FARE }

  describe '#balance' do
    it 'check a new card has a balance of zero' do
      expect(subject.balance).to eq 0
    end
  end

  describe '#top_up' do
    it 'allow a card to be topped up' do
      expect{ oystercard.top_up 1 }.to change{ oystercard.balance }.by 1
    end
    it 'throws exception if top-up limit is exceeded' do
      expect { oystercard.top_up maximum_balance + 1 }
        .to raise_error "Card limit #{maximum_balance} exceeded!"
    end
  end

  describe '#in_journey' do
    it 'returns status' do
      expect(oystercard).not_to be_in_journey
    end
  end

  describe '#touch_in' do

    it 'updates in_journey to true' do
      oystercard.top_up(minimum_balance)
      oystercard.touch_in(entry_station)
      expect(oystercard).to be_in_journey
    end
    it 'only allows touch in if the card has a minimum balance' do
      expect { oystercard.touch_in(entry_station) }
        .to raise_error "Card balance below minimum of #{minimum_balance}!"
    end

    it 'notes the entry station of a journey' do
      oystercard.top_up(minimum_balance)
      oystercard.touch_in(entry_station)
      expect(oystercard.entry_station).to eq(entry_station)
    end
  end

  describe '#touch_out' do

    it 'updates in_journey to false' do
      oystercard.touch_out exit_station
      expect(oystercard).not_to be_in_journey
    end
    it 'deducts the minimum fare' do
      oystercard.top_up(minimum_balance)
      oystercard.touch_in(entry_station)
      expect { oystercard.touch_out(exit_station) }.to change {oystercard.balance}.by(-minimum_fare)
    end
    it 'resets entry_station to nil when touching out' do
      oystercard.top_up(minimum_balance)
      oystercard.touch_in(entry_station)
      expect { oystercard.touch_out(exit_station) }.to change { oystercard.entry_station }.to(nil)
    end
  end

  describe '#journey_history' do

    let(:journey) { (Hash.new(entry_station: entry_station, exit_station: exit_station)) }

    it 'returns journey history' do
      oystercard.top_up maximum_balance
      oystercard.touch_in entry_station
      oystercard.touch_out exit_station
      expect(oystercard.journey_history).to include journey
    end
  end

end
