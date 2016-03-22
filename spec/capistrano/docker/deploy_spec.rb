require 'spec_helper'

describe Capistrano::Docker::Deploy do
  it 'has a version number' do
    expect(Capistrano::Docker::Deploy::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
