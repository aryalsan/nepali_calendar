module NepaliCalendar
  class BsCalendar < NepaliCalendar::Calendar

    MONTHNAMES = %w{nil Baisakh Jestha Ashad Shrawn Bhadra Ashwin Kartik Mangshir Poush Magh Falgun Chaitra}
    DAYNAMES = %w{nil Aitabar Sombar Mangalbar Budhbar Bihibar Sukrabar Sanibar}

    class << self
      def ad_to_bs(year, month, day)
        fail 'Invalid date!' unless valid_date?(year, month, day)

        ref_day_eng = Date.parse(ref_date['ad_to_bs']['ad'])
        date_ad = Date.parse("#{year}/#{month}/#{day}")
        return unless date_in_range?(date_ad, ref_day_eng)

        days = total_days(date_ad, ref_day_eng)
        get_bs_date(days, ref_date['ad_to_bs']['bs'])
      end

      def get_bs_date(days, ref_day_nep)
        year, month, day = ref_day_nep.split('/').map(&:to_i)
        i, j, wday = year, month, 7

        while days != 0
          bs_month_days = NepaliCalendar::BS[i][j - 1]
          day += 1
          wday += 1

          if day > bs_month_days
            month += 1
            day = 1
            j += 1
          end

          wday = 1 if wday > 7

          if month > 12
            year += 1
            month = 1
          end

          if j > 12
            j  = 1
            i += 1
          end
          days -= 1
        end

        month_name, wday_name = MONTHNAMES[month], DAYNAMES[wday]

        options = { year: year, month: month, day: day, wday: wday,
          month_name: month_name, wday_name: wday_name }
        new('', options)
      end

      def today
        date = Date.today
        ad_to_bs(date.year, date.month, date.day)
      end
    end

    def beginning_of_week
      new_day, new_month = day, month
      if wday > 1
        if day < wday
          new_month -= 1
          new_day += month_days(year, month - 2)
        end
        new_day = new_day - wday + 1
      end
      bs_date(year, new_month, new_day)
    end

    def end_of_week
      new_day, new_month = day, month
      if wday < 7
        add_days = 7 - wday
        new_day += add_days
        if new_day > month_days(year, month - 1)
          new_month += 1
          new_day -= month_days(year, month - 1)
        end
      end
      bs_date(year, new_month, new_day)
    end

    def beginning_of_month
      bs_date(year, month, 1)
    end

    def end_of_month
      bs_date(year, month, month_days(year, month - 1))
    end

    private
      def bs_date(year, month, day)
        ad = NepaliCalendar::AdCalendar.bs_to_ad(year, month, day)
        NepaliCalendar::BsCalendar.ad_to_bs(ad.year, ad.month, ad.day)
      end

      def month_days(year, month)
         NepaliCalendar::BS[year][month]
      end
  end
end
