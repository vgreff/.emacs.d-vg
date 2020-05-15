/******************************************************************************
 *
 * Copyright (c) test_table_operations.hpp by Daniel Davidson
 *
 * All Rights Reserved. 
 *******************************************************************************/
/*! 
 * \file test_table_operations.hpp
 *
 * \brief Test basic methods on database table class
 * 
 */
#ifndef _ETF_ORM_TEST_TEST_TABLE_OPERATIONS_H_
#define _ETF_ORM_TEST_TEST_TABLE_OPERATIONS_H_

#include "etf/utils/streamers/containers.hpp"
#include <algorithm>
#include <set>
#include <iterator>

namespace etf {
namespace orm {
namespace test {

  //! Test basic methods on database table class
  template < typename TABLE_CLASS > 
  class Test_table_operations 
  {
  public:
  
    // Class typedefs
    typedef typename TABLE_CLASS::Pointer_t Pointer_t;
    typedef typename TABLE_CLASS::Row_list_t Row_list_t;
    typedef typename TABLE_CLASS::Pkey_list_t Pkey_list_t;
    typedef typename TABLE_CLASS::Value_list_t Value_list_t;
    typedef typename TABLE_CLASS::Row_t Row_t;
  
    explicit Test_table_operations(
      Pointer_t const& table_class
    ) :
      table_class_(table_class),
      initial_select_all_results_()
    {
      ctor_member_init();
    }
    /////////////////////////////////////////////////////////////////
    // member accessors
    /////////////////////////////////////////////////////////////////
    Pointer_t const& table_class() const {
      return table_class_;
    }
  
    Row_list_t const& initial_select_all_results() const {
      return initial_select_all_results_;
    }
  
  private:
  
// custom <Test_table_operations private header section>

    void initial_select_all_rows() {
      table_class_->select_all_rows(initial_select_all_results_);
      BOOST_REQUIRE(initial_select_all_results_.size() > 0);
      std::cout << "Selected " << initial_select_all_results_.size() 
                << " rows from table <" << TABLE_CLASS::table_name()
                << ">\n";
    }

    void find_row_by_pkey() {
      {
        typename TABLE_CLASS::Row_list_t::const_iterator it(initial_select_all_results_.begin());
        typename TABLE_CLASS::Row_list_t::const_iterator end(initial_select_all_results_.end());
        size_t count(0);
        for(; it != end; ++it) {
          typename TABLE_CLASS::Value_t value;
          table_class_->find_row(it->first, value);
          BOOST_REQUIRE(it->second == value);
          ++count;
        }
        BOOST_REQUIRE(count == initial_select_all_results_.size());
        std::cout << "Selected " << count
                  << " rows by pkey from table <" << TABLE_CLASS::table_name()
                  << ">\n";

      }
    }

    void find_rows_by_pkey_list() {
      typename TABLE_CLASS::Pkey_list_t primary_key_list;
      typename TABLE_CLASS::Value_list_t value_list;
      {
        typename TABLE_CLASS::Row_list_t::const_iterator it(initial_select_all_results_.begin());
        typename TABLE_CLASS::Row_list_t::const_iterator end(initial_select_all_results_.end());
        for(; it != end; ++it) {
          primary_key_list.push_back(it->first);
          value_list.push_back(it->second);
        }
        BOOST_REQUIRE(primary_key_list.size() == initial_select_all_results_.size());
      }
      {
        typename TABLE_CLASS::Value_list_t value_list_for_check;
        table_class_->find_rows(primary_key_list, value_list_for_check);
        BOOST_REQUIRE(primary_key_list.size() == initial_select_all_results_.size());
        BOOST_REQUIRE(value_list_for_check == value_list);
        std::cout << "Selected " << value_list_for_check.size() 
                  << " rows by pkey list from table <" << TABLE_CLASS::table_name()
                  << ">\n";
      }
    }

    void delete_all_rows() {
      size_t rows_deleted(table_class_->delete_all_rows());
      BOOST_REQUIRE(initial_select_all_results_.size() == rows_deleted);
      std::cout << "Deleted all " << rows_deleted << " from table <"
                << TABLE_CLASS::table_name() << ">\n";
    }

    void delete_all_rows_by_pkey() {
      Row_list_t current_rows;
      table_class_->select_all_rows(current_rows);
      typename TABLE_CLASS::Row_list_t::const_iterator it(current_rows.begin());
      typename TABLE_CLASS::Row_list_t::const_iterator end(current_rows.end());
      size_t count(0);
      for(; it != end; ++it, ++count) {
        table_class_->delete_row(it->first);
      }

      std::cout << "Deleted all " << count
                << " rows by pkey from table <" << TABLE_CLASS::table_name() << ">\n";
    }

    void delete_all_rows_by_pkey_list(int max_per_call = 0) {
      Row_list_t current_rows;
      table_class_->select_all_rows(current_rows);
      typename TABLE_CLASS::Pkey_list_t primary_key_list;
      typename TABLE_CLASS::Row_list_t::const_iterator it(current_rows.begin());
      typename TABLE_CLASS::Row_list_t::const_iterator end(current_rows.end());
      size_t count(0);
      for(; it != end; ++it, ++count) {
        primary_key_list.push_back(it->first);
      }

      table_class_->delete_rows(primary_key_list, max_per_call);

      std::cout << "Deleted all " << count << " rows by pkey list ";
      if(max_per_call) {
        std::cout << max_per_call << " per sql call ";
      }
      std::cout << "from table <" << TABLE_CLASS::table_name() << ">\n";
    }

    bool current_row_values_match_originals() {
      Row_list_t current_rows;
      table_class_->select_all_rows(current_rows);
      typename TABLE_CLASS::Row_list_t::const_iterator it(initial_select_all_results_.begin());
      typename TABLE_CLASS::Row_list_t::const_iterator end(initial_select_all_results_.end());
      typename TABLE_CLASS::Row_list_t::const_iterator current_it(current_rows.begin());
      typename TABLE_CLASS::Row_list_t::const_iterator current_end(current_rows.end());

      typedef std::set< typename TABLE_CLASS::Value_t > Value_set_t;
      Value_set_t original;
      Value_set_t current;
      for(; (it != end) && (current_it != current_end); ++it, ++current_it) {
        original.insert(it->second);
        current.insert(current_it->second);
      }
      BOOST_REQUIRE(original == current);

      std::cout << "Row values " << initial_select_all_results_.size() 
                << " match originals from table <" << TABLE_CLASS::table_name() << ">\n";
      return initial_select_all_results_.size() == current_rows.size();
    }

    void insert_rows_by_row() {
      typename TABLE_CLASS::Row_list_t::const_iterator it(initial_select_all_results_.begin());
      typename TABLE_CLASS::Row_list_t::const_iterator end(initial_select_all_results_.end());
      for(; it != end; ++it) {
        table_class_->insert(*it);
      }
      BOOST_REQUIRE(current_row_values_match_originals());
    }

    void insert_rows_by_list() {
      table_class_->insert(initial_select_all_results_);
      BOOST_REQUIRE(current_row_values_match_originals());
    }

    void update_rows() {
      table_class_->update(initial_select_all_results_);
      Row_list_t current_rows;
      table_class_->select_all_rows(current_rows);
      BOOST_REQUIRE(current_row_values_match_originals());
    }

    void update_rows_reverse() {
      typename TABLE_CLASS::Row_list_t update_rows;
      typename TABLE_CLASS::Row_list_t::const_iterator it(initial_select_all_results_.begin());
      typename TABLE_CLASS::Row_list_t::const_iterator end(initial_select_all_results_.end());
      typename TABLE_CLASS::Row_list_t::const_reverse_iterator rbegin(initial_select_all_results_.end());  
      for(; it != end; ++it, ++rbegin) {
        update_rows.push_back(Row_t(it->first, rbegin->second));
      }
      table_class_->update(update_rows);
      Row_list_t current_rows;
      table_class_->select_all_rows(current_rows);
      typedef std::set< typename TABLE_CLASS::Value_t > Item_set_t;
      Item_set_t update_set;
      Item_set_t current_set;

      BOOST_REQUIRE(update_rows.size() == current_rows.size());
      it = update_rows.begin();
      end = update_rows.end();
      typename TABLE_CLASS::Row_list_t::const_iterator current_it(current_rows.begin());
      for(; it != end; ++it, ++current_it) {
        update_set.insert(it->second);
        current_set.insert(current_it->second);
      }

      using etf::utils::streamers::operator<<;
      bool are_equal(update_set == current_set);
      if(!are_equal) {
        std::cout << "-- FIRST --\n" << update_set << "\n-- SECOND --\n" << current_set << std::endl;
      }
      BOOST_REQUIRE(are_equal);
      std::cout << "Updated all " << update_rows.size()
                << " rows by pkey from table <" << TABLE_CLASS::table_name() << ">\n";
    }

    void update_by_value() {
      Row_list_t current_rows;
      table_class_->select_all_rows(current_rows);
      BOOST_REQUIRE(current_row_values_match_originals());
      BOOST_REQUIRE(initial_select_all_results_.size() > 1);
      typename TABLE_CLASS::Row_t const& front(current_rows.front());
      typename TABLE_CLASS::Row_t const& back(current_rows.back());
      bool front_back_differ(!(front.second == back.second));
      if(!front_back_differ) {
        std::cerr << "To test update_by_value values of first record and last record must differ in some way" << std::endl;
      }
      BOOST_REQUIRE(front_back_differ);
      typename TABLE_CLASS::Value_update_t value_update(front.second, back.second);
#if defined(EXTRA_LOGGING)      
      using etf::utils::streamers::operator<<;
      std::cout << "---- Value Update ----\n";
      value_update.dump(std::cout);
      std::cout << "\n---- To Make This First ----\n" << front
                << "\n---- Equal This second ----\n" << back
                << std::endl;
#endif
      table_class_->update(front.first, value_update);

      typename TABLE_CLASS::Value_t check_value;
      table_class_->find_row(front.first, check_value);
#if defined(EXTRA_LOGGING)      
      std::cout << "\n---- FIRST AFTER ----\n" << check_value << std::endl;
#endif
      BOOST_REQUIRE(back.second == check_value);
      typename TABLE_CLASS::Row_list_t back_to_original;
      back_to_original.push_back(front);
      table_class_->update(back_to_original);
      BOOST_REQUIRE(current_row_values_match_originals());
      std::cout << "Update by value is working on <" << TABLE_CLASS::table_name() << ">\n";
    }

// end <Test_table_operations private header section>
  
    //! Initialize the instance
    inline void ctor_member_init() {
      
// custom <Test_table_operations::init>

      initial_select_all_rows();
      find_row_by_pkey();
      find_rows_by_pkey_list();
      delete_all_rows();
      size_t affected(table_class_->select_affected_row_count());
      size_t initial_size(initial_select_all_results_.size());
      if(initial_size != affected) {
        std::cout << "Failing on initial_size (" << initial_size 
                  << ") vs affected (" << affected << ")" << std::endl;
      }
      BOOST_REQUIRE(initial_size == affected);
      BOOST_REQUIRE(0 == table_class_->select_table_row_count());
      std::cout << "Last insert id:" << table_class_->select_last_insert_id() << std::endl;
      insert_rows_by_row();
      std::cout << "Affected rows:" << table_class_->select_affected_row_count() << std::endl;
      BOOST_REQUIRE(initial_select_all_results_.size() == table_class_->select_table_row_count());
      delete_all_rows_by_pkey();
      insert_rows_by_list();
      delete_all_rows_by_pkey_list();
      insert_rows_by_list();
      delete_all_rows_by_pkey_list(7);
      insert_rows_by_list();
      update_rows_reverse();
      update_rows();
      update_by_value();

// end <Test_table_operations::init>
    }
    //! Class front-ending the database table <I>read only</I>
    Pointer_t table_class_;
    //! Results of initial select <I>read only</I>
    Row_list_t initial_select_all_results_;
  };

} // namespace test
} // namespace orm
} // namespace etf
#endif // _ETF_ORM_TEST_TEST_TABLE_OPERATIONS_H_
