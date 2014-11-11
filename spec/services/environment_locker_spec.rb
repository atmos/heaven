require "spec_helper"

describe EnvironmentLocker do
  let(:redis) { double(:redis) }

  let(:lock_params) do
    {
      :name_with_owner => "atmos/heaven",
      :environment => "production",
      :actor => "atmos"
    }
  end

  describe "#lock?" do
    it "is true if the task is deploy:lock" do
      locker = EnvironmentLocker.new(lock_params.merge(:task => "deploy:lock"))
      locker.redis = redis

      expect(locker.lock?).to be_true
    end
  end

  describe "#unlock?" do
    it "is true if the task is deploy:unlock" do
      locker = EnvironmentLocker.new(lock_params.merge(:task => "deploy:unlock"))
      locker.redis = redis

      expect(locker.unlock?).to be_true
    end
  end

  describe "#lock!" do
    it "locks the environment for the repo and records the locker" do
      locker = EnvironmentLocker.new(lock_params)
      locker.redis = redis

      expect(locker.actor).to eq("atmos")

      expect(redis).to receive(:set).with("atmos/heaven-production-lock", "atmos")

      locker.lock!

      expect(redis).to receive(:get).with("atmos/heaven-production-lock").and_return("atmos")

      expect(locker.locked_by).to eq("atmos")
    end
  end

  describe "#unlock!" do
    it "unlocks the environment for the repo" do
      locker = EnvironmentLocker.new(lock_params)
      locker.redis = redis

      expect(redis).to receive(:del).with("atmos/heaven-production-lock")

      locker.unlock!
    end
  end

  describe "#locked?" do
    let(:locker) do
      EnvironmentLocker.new(lock_params).tap do |locker|
        locker.redis = redis
      end
    end

    it "is true if the repo/environment pair exists" do
      expect(redis).to receive(:exists).with("atmos/heaven-production-lock").and_return(true)

      expect(locker.locked?).to be_true
    end

    it "is false if the repo/environment pair exists" do
      expect(redis).to receive(:exists).with("atmos/heaven-production-lock").and_return(false)

      expect(locker.locked?).to be_false
    end
  end

  describe "#locked_by" do
    it "returns the user who locked the environment" do
      locker = EnvironmentLocker.new(lock_params)
      locker.redis = redis

      expect(redis).to receive(:get).with("atmos/heaven-production-lock").and_return("atmos")

      expect(locker.locked_by).to eq("atmos")
    end
  end
end
