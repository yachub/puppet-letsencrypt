# frozen_string_literal: true

require 'spec_helper'

describe 'letsencrypt::plugin::dns_route53' do
  on_supported_os.each do |os, facts|
    context "on #{os} based operating systems" do
      let(:facts) { facts }
      let(:params) { {} }
      let(:pre_condition) do
        <<-PUPPET
        class { 'letsencrypt':
          email => 'foo@example.com',
        }
        PUPPET
      end
      let(:package_name) do
        osname = facts[:os]['name']
        osrelease = facts[:os]['release']['major']
        osfull = "#{osname}-#{osrelease}"
        case osfull
        when 'Debian-10', 'Debian-11', 'AlmaLinux-8', 'RedHat-8', 'Ubuntu-20.04', 'Ubuntu-18.04', 'Fedora-32'
          'python3-certbot-dns-route53'
        when 'RedHat-7', 'CentOS-7'
          'python2-certbot-dns-route53'
        when 'FreeBSD-12', 'FreeBSD-13'
          'py39-certbot-dns-route53'
        end
      end

      context 'with required parameters' do
        it do
          if package_name.nil?
            is_expected.not_to compile
          else
            is_expected.to compile.with_all_deps
          end
        end

        describe 'with manage_package => true' do
          let(:params) { super().merge(manage_package: true) }

          it do
            if package_name.nil?
              is_expected.not_to compile
            else
              is_expected.to contain_class('letsencrypt::plugin::dns_route53').with_package_name(package_name)
              is_expected.to contain_package(package_name).with_ensure('installed')
            end
          end
        end

        describe 'with manage_package => false' do
          let(:params) { super().merge(manage_package: false, package_name: 'dns-route53-package') }

          it { is_expected.not_to contain_package('dns-route53-package') }
        end
      end
    end
  end
end
